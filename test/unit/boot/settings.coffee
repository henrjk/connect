# Test dependencies
chai        = require 'chai'
sinon       = require 'sinon'
sinonChai   = require 'sinon-chai'
expect      = chai.expect

proxyquire = require 'proxyquire'


# Configure Chai and Sinon
chai.use sinonChai
chai.should()


describe 'Test on settings', ->

    cwd         = process.cwd()
    env         = process.env.NODE_ENV || 'development'
    fs          = require 'fs'
    path        = require 'path'

    {settings} = {}

    describe 'without a config file', ->

      before ->
        config = path.join(cwd, 'config', env + '.json')
        origReadFileSync = fs.readFileSync
        sinon.stub fs, 'readFileSync', (file, options)->
          if file == config
            return JSON.stringify({
                issuer: 'http://localhost:3000',
              })
          else
            origReadFileSync.call(fs, file, options)

        proxyquire.noPreserveCache()
        settings = proxyquire('../../../boot/settings', {})

      after ->
        fs.readFileSync.restore()
        proxyquire.preserveCache()
        # User.list.restore()

      it 'settings.providers is not undefined', ->
        expect(settings.providers).to.not.be.undefined

      # cookie_secret and session_secret could also be defined but we should adjust this test if that changes.
      it 'settings.cookie_secret is undefined', ->
        expect(settings.cookie_secret).to.be.undefined

      it 'settings.session_secret is undefined', ->
        expect(settings.cookie_secret).to.be.undefined
