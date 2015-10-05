/**
 * Module dependencies
 */

var express = require('express')
var _ = require('lodash')
var url = require('url')
var settings = require('../boot/settings')
var mailer = require('../boot/mailer')
var authenticator = require('../lib/authenticator')
var oidc = require('../oidc')
var User = require('../models/User')
var OneTimeToken = require('../models/OneTimeToken')
var InvalidRequestError = require('../errors/InvalidRequestError')
var PasswordlessDisabledError = require('../errors/PasswordlessDisabledError')

/**
 * Passwordless
 *
 * Both new and existing users start at the signin page
 *
 * Common flow to signin or signup, starting at /signin :

 * 1. User provides email
 * 2. Validate input as valid email, display error if not.
 * 3. Check whether user account exists.
 * 4. Send link in either case with a one time token expiring
 *    after 15 minutes by default.
 * 4.1 If user account exists email tells user to click and confirm
 *     that they want to sign in.
 *     Link to route /signin/pwless/...
 * 4.2 If new user email tells user to click the link if that want
 *     to create a new user account.
 *     Link to route /signup/pwless/...
 *
 * New user passwordless signup flow:  (/signup/pwless)
 *
 * 1. Verify token exists and is for pwless.
 * 2. Direct user to new passwordless user view, where user can enter additional details such as last name, first name.
 * 3. Create user based on form information, revoke token.
 * 4. Send welcome mail.
 * 5. Authorize user
 *
 * Existing user passwordless sigin flow:  (/signin/pwless)
 *
 * 1. Verify token exists and is for pwless.
 * 2. Update user email verified status with current time.
 * 3. Authorize user.
 */

var TOKEN_USAGE_SIGNIN = 'pwless-signin'
var TOKEN_USAGE_SIGNUP = 'pwless-signup'

var CONNECT_SUB_FIELDS = [
  'email', 'redirect_uri', 'client_id', 'response_type', 'scope', 'nonce'
]

function verifyPasswordlessEnabled (req, res, next) {
  if (!settings.providers.passwordless) {
    return next(new PasswordlessDisabledError())
  } else {
    return next()
  }
}

function consumeToken (req, res, next) {
  if (!req.query.token) {
    return next(new InvalidRequestError('Missing token'))
  }
  // consume the token
  OneTimeToken.consume(req.query.token, function (err, token) {
    if (err) { return next(err) }
    req.token = token
    next()
  })
}

function extractTokenSub (req, res, next) {
  if (!req.token) {
    return next()
  }
  var token = req.token
  if (!token.sub) {
    return next()
  }
  var subObject
  try {
    subObject = JSON.parse(token.sub)
  } catch (err) {
    return next(err)
  }
  req.connectParams = _.pick(subObject, CONNECT_SUB_FIELDS)
  if (subObject.user) {
    req.user_id = subObject.user
  }
  next()
}

// perhaps this should be dispached by the authenticator
// however I am not sure I see what that would bring?
function verifyPasswordlessSigninToken (req, res, next) {
  var view = 'passwordless/pwlessSigninLinkVerified'
  var token = req.token

  // Invalid or expired token
  if (!token || token.use !== TOKEN_USAGE_SIGNIN) {
    return res.render(view, {
      error: 'Invalid or expired link'
    })
  }

  if (!req.user_id || !req.user_id.trim()) {
    return res.render(view, {
      error: 'Invalid or expired link'
    })
  }

  // Update the user
  User.patch(req.user_id, {
    dateEmailVerified: Date.now(),
    emailVerified: true
  }, function (err, user) {
    if (err) { return next(err) }

    // unknown user, might happen if token expired or
    // link activated twice.
    if (!user) {
      return res.render(view, {
        error: 'Unable to verify email for this user.'
      })
    }

    // analog to Password signin handler after authenticator.dispatch
    // authenticated user based on password.
    req.user = user
    authenticator.login(req, user)
    next()
  })
}

function signinRenderErrorInvalidEmail (req, res, next) {
  if (typeof req.connectParams.email === 'undefined') {
    return res.render('signin', {
      error: 'Please enter a valid e-mail address.'
    })
  }
  next()
}

function sendMail (req, res, next) {
  User.getByEmail(req.connectParams.email, function (err, user) {
    if (err) { return next(err) }

    // TODO: There may be differences in processing delays
    // whether user has an account or not. This could potentially
    // be used for an attack.

    // user = null is treated as new signup.
    // The email send is tailored to whether it is a new sign up or
    // a sign in of an existing user

    var subObject = _.pick(req.connectParams, CONNECT_SUB_FIELDS)
    if (user) {
      subObject.user = user._id
    }

    var email = subObject.email

    var tokenOptions = {
      ttl: settings.providers.passwordless.tokenTTL || 60 * 15,
      use: user ? TOKEN_USAGE_SIGNIN : TOKEN_USAGE_SIGNUP,
      sub: subObject
    }
    OneTimeToken.issue(tokenOptions, function (err, token) {
      if (err) { return next(err) }

      var verifyURL = url.parse(settings.issuer)
      verifyURL.pathname = user ? 'signin/pwless' : 'signup/pwless'
      verifyURL.query = { token: token._id }

      var template = user ? 'passwordlessSignin' : 'passwordlessSignup'
      var subject = user
        ? 'Sign in to ' + req.client.client_name
        : 'Create your account on ' + req.client.client_name

      // TODO: test is {{providerName}} available in template?
      // TODO: see also usage of #{signin.client.client_name} in verifyEmail.jade, oidc.verifyClient

      mailer.sendMail(template, {
        email: email,
        verifyURL: url.format(verifyURL)
      }, {
        to: email,
        subject: subject
      }, function (err, responseStatus) {
        if (err) { }         // TODO: REQUIRES REFACTOR TO MAIL QUEUE
        renderSentMail(req, res, next)
      })
    })
  })
}

function renderSentMail (req, res, next) {
  // this is similar to the middleware in requireVerifiedEmail
  // but there are differences:
  // 1. Not sure role.name authority handling makes sense here.
  // 2. emailVerified is no reason to skip this.
  // 3. Resend URL has different path ('resend/passwordless' instead of 'email/resend')
  // 3. The messages are differently worded to the case.
  // So perhaps not sharing will make this somewhat easier.

  var resendURL = url.parse(settings.issuer)
  resendURL.pathname = 'resend/passwordless'
  resendURL.query = {
    email: req.connectParams.email
  }
  if (req.connectParams) {
    resendURL.query.redirect_uri = req.connectParams.redirect_uri
    resendURL.query.client_id = req.connectParams.client_id
    resendURL.query.response_type = req.connectParams.response_type
    resendURL.query.scope = req.connectParams.scope
  }
  var locals = {
    from: mailer.from,
    resendURL: url.format(resendURL)
  }
  res.render('passwordless/pwlessSentEmail', locals)
}

/*
 * It is expected that the following middleware is used prior
 * to this:
 oidc.selectConnectParams,
 oidc.verifyClient,
 oidc.validateAuthorizationParams,
 oidc.determineProvider.setup({requireProvider: true}),
 oidc.enforceReferrer('/signin'),
 In addition it was checked that req.body.provider === 'passwordless'
 */

function postSigninMiddleware () {
  var middleware = express.Router()
  var handler = [
    verifyPasswordlessEnabled,
    oidc.verifyMailerConfigured,
    oidc.verifyEmailValid,
    signinRenderErrorInvalidEmail,
    sendMail
  ]
  middleware.use(handler)
  function passwordlessSignin (req, res, next) {
    // allows setting a breakpoint here and some nicer stack traces.
    middleware(req, res, next)
  }
  return passwordlessSignin
}

// signin/pwless, signup/pwless,
function routes (server) {
  server.get('/resend/:provider',
    oidc.selectConnectParams,
    oidc.verifyClient,
    oidc.validateAuthorizationParams,
    oidc.determineProvider.setup({requireProvider: true}),
    verifyPasswordlessEnabled,
    oidc.verifyMailerConfigured,
    oidc.verifyEmailValid,
    function (req, res, next) {
      if (typeof req.connectParams.email === 'undefined') {
        next(new InvalidRequestError('invalid email'))
      }
      next()
    },
    sendMail
  )
  server.get('/signin/:provider',
    consumeToken,
    extractTokenSub,
    oidc.verifyClient,
    oidc.validateAuthorizationParams,
    oidc.determineProvider.setup({requireProvider: true}),
    verifyPasswordlessEnabled,
    verifyPasswordlessSigninToken,
    oidc.determineUserScope,
    oidc.promptToAuthorize,
    oidc.authorize
  )

  // TODO: server.get('/signup/:provider'
}

module.exports = {
  routes: routes,
  signin: postSigninMiddleware,
  oidc: {
    verifyEnabled: verifyPasswordlessEnabled,
    consumeToken: consumeToken,
    extractTokenSub: extractTokenSub,
    verifyToken: verifyPasswordlessSigninToken,
    enterValidEmailError: signinRenderErrorInvalidEmail,
    sendMail: sendMail
  }
}
