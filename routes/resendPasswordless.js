/**
 * Module dependencies
 */

var oidc = require('../oidc')
var passwordless = require('./passwordless')
var InvalidRequestError = require('../errors/InvalidRequestError')

/**
 * Resend passwordless signin or signup e-mail message endpoint
 */

module.exports = function (server) {
  server.get('/pwless/resend', [
    oidc.selectConnectParams,
    oidc.verifyRedirectURI,
    passwordless.verifyEnabled,
    oidc.verifyMailerConfigured,
    oidc.verifyEmailValid,
    function (req, res, next) {
      if (typeof req.connectParams.email === 'undefined') {
        return next(new InvalidRequestError())
      }
    },
    passwordless.sendEmail
  ])
}
