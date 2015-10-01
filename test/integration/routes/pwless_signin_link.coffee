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
express = require 'express'
server = require '../../../server'
Client = require('../../../models/Client')
User = require('../../../models/User')
OneTimeToken = require '../../../models/OneTimeToken'
Scope = require('../../../models/Scope')
IDToken = require '../../../models/IDToken'
AccessToken = require '../../../models/AccessToken'

TestSettings = require '../../lib/testSettings'

#server = express()
#server.get('/XXX-signin/passwordless', (req, res) ->
#  res.redirect('http://localhost:9000/callback_html');
#);
#require('../../../boot/server')(server)
#passwordless.routes(server)

request = supertest(server)

describe 'Passwordless signin link activation', ->

  settings = require '../../../boot/settings'

  tsSettings = {}

  before ->
    tsSettings = new TestSettings(settings,
      _.pick(settings, ['response_types_supported', 'keys']))

    tsSettings.addSettings
      issuer: 'https://test.issuer.com'
      providers:
        passwordless:
          "tokenTTL-foo": 600

  after ->
    tsSettings.restore()

  {err, res} = {}


  describe 'success flow existing user sign-IN', ->
    tokenOptions = {}
    {scope,scopes} = {}

    before (done) ->
      tokenOptions =
        exp: Math.round(Date.now() / 1000) + 3600
        use: 'pwless-signin'
        sub: JSON.stringify
          email: 'peter@mary.com'
          client_id: '4a2c1a31-150d-49e3-9946-2909220cdb16'
          redirect_uri: 'http://localhost:9000/callback_popup.html'
          response_type: 'id_token token'
          scope: 'openid profile'
          nonce: 'KG4vsD0bfAjbEdCMurmiPxzEcpFGoguYGR7b3cj3AMs'
          user: 'peters-user-uuid'

      sinon.stub(OneTimeToken, 'consume')
        .callsArgWith(1, null, new OneTimeToken tokenOptions)

      sinon.stub(Client, 'get').callsArgWith(2, null,
        {
          client_name: 'unit test pwless_signin'
          _id: '4a2c1a31-150d-49e3-9946-2909220cdb16'
          redirect_uris: [
            'http://localhost:9000/callback_popup.html'
          ]
          trusted: true
          response_types: ['id_token token']
          grant_types: ['implicit']
        })

      user = new User _id: tokenOptions.sub.user

      sinon.stub(User, 'patch').callsArgWith(2, null, user)

      scope  = 'openid profile developer'
      scopes = [
        new Scope name: 'openid'
        new Scope name: 'profile'
        new Scope name: 'developer'
      ]
      sinon.stub(Scope, 'determine').callsArgWith(2, null, scope, scopes)

      response = AccessToken.initialize().project('issue')
      sinon.stub(AccessToken, 'issue').callsArgWith(1, null, response)
      sinon.spy(IDToken.prototype, 'initializePayload')

      sinon.spy(express.response, 'redirect')

      query =
        token: 'token-id-random-stuff'

      request
        .get('/signin/passwordless')
        .redirects(0)
        .query(query)
        .end (error, response) ->
          console.log('request.end callback called', error, response)
          err = error
          res = response
          done()

    after ->
      console.log('after() entering')
      express.response.redirect.restore();
      AccessToken.issue.restore()
      IDToken.prototype.initializePayload.restore()
      Scope.determine.restore()
      User.patch.restore()
      OneTimeToken.consume.restore()
      Client.get.restore()

    it 'should consume with the query id', ->
      console.log('it 1 called')
      OneTimeToken.consume.should.have.been.calledWith 'token-id-random-stuff'

    it 'should redirect to the callback with the proper tokens', ->
      console.log('it 2 called')
      express.response.redirect.should.have.been.calledWith sinon.match( /callback/ )
