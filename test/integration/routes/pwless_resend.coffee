# Test dependencies
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
supertest = require 'supertest'
expect = chai.expect
qs = require 'qs'


# Assertions
chai.use sinonChai
chai.should()


# First load modules which are stubbed for the test:
proxyquire = require 'proxyquire'

getMailer = () ->
  from: "from@example.com"
  render: {}
  transport: {}
  sendMail: (template, locals, options, callback) ->
    callback(null, null) # error, info

mailerStub =
  getMailer: getMailer


mailer = proxyquire('../../../oidc/verifyMailerConfigured', {'../boot/mailer' : mailerStub})

mailer = proxyquire('../../../routes/passwordless', {'../boot/mailer' : mailerStub})

# Code under test
server = require '../../../server'
Client = require('../../../models/Client')
User = require('../../../models/User')

request = supertest(server)


describe 'Passwordless resend email route', ->


  {err, res} = {}


  describe 'GET resend/passwordless', ->

    describe 'without valid token', ->

      before (done) ->

        sinon.stub(Client, 'get').callsArgWith(2, null,
          {
            client_name: 'unit test pwless_resend'
            redirect_uris: [
              'http://localhost:9000/callback_popup.html'
            ]
            trusted: true
            response_types: ['id_token token']
            grant_types: ['implicit']
          })

        mailerStub.getMailer = getMailer

        sinon.stub(User, 'getByEmail').callsArgWith(1, null, null)

        query =
          client_id: '4a2c1a31-150d-49e3-9946-2909220cdb16'
          redirect_uri: 'http://localhost:9000/callback_popup.html'
          response_type: 'id_token token'
          scope: 'openid profile'
          nonce: 'KG4vsD0bfAjbEdCMurmiPxzEcpFGoguYGR7b3cj3AMs'
          email: 'foo@example.com'

        request
          .get('/resend/passwordless?' + qs.stringify(query))
          .end (error, response) ->
            err = error
            res = response
            done()

      after ->
        User.getByEmail.restore()
        Client.get.restore()
        delete mailerStub.getMailer

      it 'should respond 200', ->
        res.statusCode.should.equal 200

      it 'should respond with an html page', ->
        res.headers['content-type'].should.contain 'text/html'

      it 'should respond with html page containing the sender', ->
        res.text.should.contain 'from@example.com'

      it 'should respond with html page containing the resend link', ->
        res.text.should.match (new RegExp("href=\"http(s){0,1}://[^/]{0,}/resend/passwordless\\?email=foo%40example\\.com&amp;", "g"))
