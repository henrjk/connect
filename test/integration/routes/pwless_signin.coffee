# Test dependencies
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
supertest = require 'supertest'
expect = chai.expect


# Assertions
chai.use sinonChai
chai.should()

_ = require 'lodash'

# Code under test
server = require '../../../server'

settings = require '../../../boot/settings'

request = supertest(server)

describe 'Passwordless signin post', ->

  mailer = require '../../../boot/mailer'
  mailer_state = {}
  fakeMailer =
    from: "from@example.com"
    render: {}
    sendMail: (tmpl, loc, opts, cb) ->
      cb()
    transport: {}

  before ->
    _.assign(mailer_state, mailer)
    _.assign(mailer, fakeMailer)

  after ->
    _.assign(mailer, mailer_state)

  {err, res} = {}


  describe 'POST signin body passwordless', ->

    describe 'success flow', ->

      settings_providers_state = {}
      pwless_settings =
        passwordless:
          "tokenTTL-foo": 600

      before (done) ->

        _.assign(settings_providers_state, settings.providers)
        _.assign(settings.providers, pwless_settings)

        # #
        #   sinon.stub(Client, 'get').callsArgWith(2, null,
        #     {
        #       client_name: 'unit test pwless_signin'
        #       redirect_uris: [
        #         'http://localhost:9000/callback_popup.html'
        #       ]
        #       trusted: true
        #       response_types: ['id_token token']
        #       grant_types: ['implicit']
        #     })
        #
        # sinon.stub(User, 'getByEmail').callsArgWith(1, null, null)

        fields =
          client_id: '4a2c1a31-150d-49e3-9946-2909220cdb16'
          redirect_uri: 'http://localhost:9000/callback_popup.html'
          response_type: 'id_token token'
          scope: 'openid profile'
          nonce: 'KG4vsD0bfAjbEdCMurmiPxzEcpFGoguYGR7b3cj3AMs'
          email: 'foo@example.com'
          provider: 'passwordless'

        request
          .post('/signin')
          .set('referer', settings.issuer + '/signin')
          .send(fields)
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        settings.providers = settings_providers_state;
        # User.getByEmail.restore()
        # Client.get.restore()

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with an html page', ->
        res.headers['content-type'].should.contain 'text/html'

      it 'should respond with html page containing the sender', ->
        res.text.should.contain 'from@example.com'

      it 'should respond with html page containing the resend link', ->
        res.text.should.match (new RegExp("href=\"http(s){0,1}://[^/]{0,}/resend/passwordless\\?email=foo%40example\\.com&amp;", "g"))
