chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
expect    = chai.expect


chai.use sinonChai
chai.should()


{passwordless} = require '../../../oidc'

# InvalidRequestError = require '../../../errors/InvalidRequestError'

settings = require '../../../boot/settings'
TestSettings = require '../../lib/testSettings'

InvalidRequestError = require '../../../errors/InvalidRequestError'
OneTimeToken = require '../../../models/OneTimeToken'


describe 'Passwordless middleware tests', ->


  {req,res,next,err, issuer} = {}

  tsSettings = {}

  describe 'passwordless enablement', ->

    describe 'verify when enabled', ->

      before ->
        tsSettings = new TestSettings(settings)
        tsSettings.addSettings
          issuer: 'https://test.issuer.com'
          providers:
            passwordless: {}
        next = sinon.spy()
        passwordless.verifyEnabled req, res, next

      after ->
        tsSettings.restore()

      it 'should continue', ->
        next.should.have.been.called

      it 'should not provide an error', ->
        next.should.not.have.been.calledWith sinon.match.defined


    describe 'verify when not enabled', ->

      before ->
        tsSettings = new TestSettings(settings)
        tsSettings.addSettings
          issuer: 'https://test.issuer.com'
          providers: {}

        next = sinon.spy()
        passwordless.verifyEnabled req, res, next

      after ->
        tsSettings.restore()

      it 'should continue', ->
        next.should.have.been.called

      it 'should provide an error', ->
        next.should.have.been.calledWith sinon.match.instanceOf(Error)

    # boot/settings will always establish a settings.providers object.

  describe 'passwordless consume link token', ->

    before ->
      tsSettings = new TestSettings(settings)
      tsSettings.addSettings
        issuer: 'https://test.issuer.com'
        providers:
          passwordless: {}

    after ->
      tsSettings.restore()

    describe 'missing token is an error', ->
      before ->
        req =
          query: {}

        next = sinon.spy()

        passwordless.consumeToken req, res, next

      it 'should continue', ->
        next.should.have.been.called

      it 'should provide an invalid request error', ->
        next.should.have.been.calledWith sinon.match.instanceOf(InvalidRequestError)

    describe 'with link token call OneTimeToken#consume', ->
      {err} = {}
      {token} = {}

      before (done) ->
        req =
          query:
            token: 'the-passwordless-token'

        next = sinon.spy (error) ->
          err = error
          done()

        token = {test: 'foo'}
        sinon.stub(OneTimeToken, 'consume').callsArgWith(1, null, token)

        passwordless.consumeToken req, res, next

      after ->
        OneTimeToken.consume.restore()

      it 'should continue', ->
        next.should.have.been.called

      it 'should not provide an error', ->
        expect(err).to.be.undefined

      it 'should set token on the request', ->
        req.token.should.equal token

    describe 'with link token call OneTimeToken#consume not found case', ->
      {err} = {}

      before (done) ->
        req =
          query:
            token: 'the-passwordless-token'

        next = sinon.spy (error) ->
          err = error
          done()

        sinon.stub(OneTimeToken, 'consume').callsArgWith(1, null, null)

        passwordless.consumeToken req, res, next

      after ->
        OneTimeToken.consume.restore()

      it 'should continue', ->
        next.should.have.been.called

      it 'should not provide an error', ->
        expect(err).to.be.undefined

      it 'should have null token on the request', ->
        expect(req.token).to.be.null

    describe 'with link token call OneTimeToken#consume error case', ->
      {err} = {}

      before (done) ->
        req =
          query:
            token: 'the-passwordless-token'

        next = sinon.spy (error) ->
          err = error
          done()

        sinon.stub(OneTimeToken, 'consume').callsArgWith(1, new Error("fake A redis DB unit test error"), null)

        passwordless.consumeToken req, res, next

      after ->
        OneTimeToken.consume.restore()

      it 'should continue', ->
        next.should.have.been.called

      it 'should provide an error', ->
        next.should.have.been.calledWith sinon.match.instanceOf(Error)

      it 'should have undefined token on the request', ->
        expect(req.token).to.be.undefined
