# Two Minutes hang during test

In integration test pwless_sigin_link.coffee sometimes The
test hangs and typically will then fail with a timeout.

This does not happen all the time. When it happens and the mocha time is set to (infinity=0) then the test hangs 2 minutes and then continues as expected.

This is on OS X 10.10.5.

It appears that this only happen when redis is not reachable. For example this happens after boot2docker download when earlier a docker redis instance was running.

There is the follwing in `/etc/hosts`

```
192.168.59.103	boot2docker redis
```

Potentially related to this could be [node issues 2642](https://github.com/nodejs/node/issues/2642)
and  https://github.com/nodejs/node-v0.x-archive/issues/9066
however it is not crystal clear exactly how a redis connection competes with the one from the test.  

## LOG:

``` console
igelmac:connect2 dev$ NODE_DEBUG=net,http:* node_modules/.bin/mocha --timeout 0  --compilers coffee:coffee-script/register ./test/integration/routes/pwless_signin_link.coffee  --reporter spec


NET 10680: createConnection [ { port: 6379, host: 'redis', family: 4 } ]
NET 10680: pipe false undefined
NET 10680: connect: find host redis
NET 10680: connect: dns options [object Object]
NET 10680: _read
NET 10680: _read wait for connection
Passwordless signin link activation
  success flow existing user sign-IN
NET 10680: listen2 null 0 4 false
NET 10680: _listen2: create a handle
NET 10680: bind to anycast
HTTP 10680: call onSocket 0 0
HTTP 10680: createConnection 127.0.0.1:50038:: { method: 'get',
port: '50038',
path: null,
host: '127.0.0.1',
ca: undefined,
agent: false,
servername: '127.0.0.1' }
NET 10680: createConnection [ { method: 'get',
  port: '50038',
  path: null,
  host: '127.0.0.1',
  ca: undefined,
  agent: false,
  servername: '127.0.0.1',
  encoding: null } ]
NET 10680: pipe false null
NET 10680: connect: find host 127.0.0.1
NET 10680: connect: dns options [object Object]
HTTP 10680: sockets 127.0.0.1:50038:: 1
HTTP 10680: outgoing message end.
last line of befor(done) executed
nextTick in before()
NET 10680: _read
NET 10680: _read wait for connection
NET 10680: onconnection
NET 10680: _read
NET 10680: Socket._read readStart
HTTP 10680: SERVER new http connection
NET 10680: afterConnect
NET 10680: _read
NET 10680: Socket._read readStart
NET 10680: onread 174
NET 10680: got data
HTTP 10680: SERVER socketOnData 174
HTTP 10680: parserOnHeadersComplete { headers:
 [ 'Host',
   '127.0.0.1:50038',
   'Accept-Encoding',
   'gzip, deflate',
   'User-Agent',
   'node-superagent/1.3.0',
   'Connection',
   'close' ],
url: '/signin/passwordless?token=token-id-random-stuff',
method: 1,
versionMajor: 1,
versionMinor: 1,
shouldKeepAlive: false,
upgrade: false }
NET 10680: _read
HTTP 10680: write ret = true
13:44:28 access: GET /signin/passwordless?token=token-id-random-stuff 302 51ms
NET 10680: onread 2962
NET 10680: got data
HTTP 10680: parserOnHeadersComplete { headers:
 [ 'Access-Control-Allow-Origin',
   '*',
   'Location',
   'http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209d',
   'Vary',
   'Accept',
   'Content-Type',
   'text/plain; charset=utf-8',
   'Content-Length',
   '1330',
   'set-cookie',
   'connect.sid=s%3AUVCFCygWVM07fIumPGL0_XpecHnPoK0j.4zBhQbTQyVhVaEanC5lOs4%2FRgdZtJbbqSruZFKJZLf0; Path=/; HttpOnly',
   'Date',
   'Thu, 01 Oct 2015 11:44:28 GMT',
   'Connection',
   'close' ],
statusCode: 302,
statusMessage: 'Moved Temporarily',
versionMajor: 1,
versionMinor: 1,
shouldKeepAlive: false,
upgrade: false }
HTTP 10680: AGENT incoming response!
HTTP 10680: AGENT isHeadResponse false
NET 10680: _read
NET 10680: _onTimeout
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: emit close

The following is repeated 210 times:

NET 10680: createConnection [ { port: 6379, host: 'redis', family: 4 } ]
NET 10680: pipe false undefined
NET 10680: connect: find host redis
NET 10680: connect: dns options [object Object]
NET 10680: _read
NET 10680: _read wait for connection
NET 10680: _onTimeout
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: emit close
.... 210 times the same as above.
NET 10680: createConnection [ { port: 6379, host: 'redis', family: 4 } ]
NET 10680: pipe false undefined
NET 10680: connect: find host redis
NET 10680: connect: dns options [object Object]
NET 10680: _read
NET 10680: _read wait for connection
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: emit close

Then there is a timeout presumably from after the _read call above.

NET 10680: createConnection [ { port: 6379, host: 'redis', family: 4 } ]
NET 10680: pipe false undefined
NET 10680: connect: find host redis
NET 10680: connect: dns options [object Object]
NET 10680: _read
NET 10680: _read wait for connection
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: emit close
NET 10680: _onTimeout
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: has server
NET 10680: SERVER _emitCloseIfDrained
NET 10680: SERVER handle? true   connections? 0
NET 10680: onread -4095
NET 10680: EOF
NET 10680: onSocketEnd { objectMode: false,
highWaterMark: 16384,
buffer: [],
length: 0,
pipes: null,
pipesCount: 0,
flowing: true,
ended: true,
endEmitted: false,
reading: false,
sync: false,
needReadable: false,
emittedReadable: false,
readableListening: false,
defaultEncoding: 'utf8',
ranOut: false,
awaitDrain: 0,
readingMore: false,
decoder: null,
encoding: null,
resumeScheduled: false }
NET 10680: onSocketFinish
NET 10680: oSF: ended, destroy { objectMode: false,
highWaterMark: 16384,
buffer: [],
length: 0,
pipes: null,
pipesCount: 0,
flowing: true,
ended: true,
endEmitted: false,
reading: false,
sync: false,
needReadable: false,
emittedReadable: false,
readableListening: false,
defaultEncoding: 'utf8',
ranOut: false,
awaitDrain: 0,
readingMore: false,
decoder: null,
encoding: null,
resumeScheduled: false }
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: close
NET 10680: close handle
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: already destroyed, fire error callbacks
NET 10680: destroy undefined
NET 10680: destroy
NET 10680: already destroyed, fire error callbacks
NET 10680: emit close
HTTP 10680: CLIENT socket onClose
HTTP 10680: removeSocket 127.0.0.1:50038:: destroyed: true
HTTP 10680: HTTP socket close
NET 10680: SERVER _emitCloseIfDrained
NET 10680: SERVER: emit close
request.end callback called null { domain: null,
_events: {},
_maxListeners: undefined,
res:
 { _readableState:
    { objectMode: false,
      highWaterMark: 16384,
      buffer: [],
      length: 0,
      pipes: null,
      pipesCount: 0,
      flowing: true,
      ended: true,
      endEmitted: true,
      reading: false,
      sync: false,
      needReadable: false,
      emittedReadable: false,
      readableListening: false,
      defaultEncoding: 'utf8',
      ranOut: false,
      awaitDrain: 0,
      readingMore: false,
      decoder: [Object],
      encoding: 'utf8',
      resumeScheduled: false },
   readable: false,
   domain: null,
   _events:
    { end: [Object],
      data: [Object],
      close: [Function],
      error: [Function] },
   _maxListeners: undefined,
   socket:
    { _connecting: false,
      _hadError: false,
      _handle: null,
      _parent: null,
      _host: '127.0.0.1',
      _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _writableState: [Object],
      writable: false,
      allowHalfOpen: false,
      destroyed: true,
      bytesRead: 2962,
      _bytesDispatched: 174,
      _pendingData: null,
      _pendingEncoding: '',
      parser: null,
      _httpMessage: [Object],
      read: [Function],
      _consuming: true,
      write: [Function: writeAfterFIN],
      _idleNext: null,
      _idlePrev: null,
      _idleTimeout: -1 },
   connection:
    { _connecting: false,
      _hadError: false,
      _handle: null,
      _parent: null,
      _host: '127.0.0.1',
      _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _writableState: [Object],
      writable: false,
      allowHalfOpen: false,
      destroyed: true,
      bytesRead: 2962,
      _bytesDispatched: 174,
      _pendingData: null,
      _pendingEncoding: '',
      parser: null,
      _httpMessage: [Object],
      read: [Function],
      _consuming: true,
      write: [Function: writeAfterFIN],
      _idleNext: null,
      _idlePrev: null,
      _idleTimeout: -1 },
   httpVersionMajor: 1,
   httpVersionMinor: 1,
   httpVersion: '1.1',
   complete: false,
   headers:
    { 'access-control-allow-origin': '*',
      location: 'http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209d',
      vary: 'Accept',
      'content-type': 'text/plain; charset=utf-8',
      'content-length': '1330',
      'set-cookie': [Object],
      date: 'Thu, 01 Oct 2015 11:44:28 GMT',
      connection: 'close' },
   rawHeaders:
    [ 'Access-Control-Allow-Origin',
      '*',
      'Location',
      'http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209d',
      'Vary',
      'Accept',
      'Content-Type',
      'text/plain; charset=utf-8',
      'Content-Length',
      '1330',
      'set-cookie',
      'connect.sid=s%3AUVCFCygWVM07fIumPGL0_XpecHnPoK0j.4zBhQbTQyVhVaEanC5lOs4%2FRgdZtJbbqSruZFKJZLf0; Path=/; HttpOnly',
      'Date',
      'Thu, 01 Oct 2015 11:44:28 GMT',
      'Connection',
      'close' ],
   trailers: {},
   rawTrailers: [],
   _pendings: [],
   _pendingIndex: 0,
   upgrade: false,
   url: '',
   method: null,
   statusCode: 302,
   statusMessage: 'Moved Temporarily',
   client:
    { _connecting: false,
      _hadError: false,
      _handle: null,
      _parent: null,
      _host: '127.0.0.1',
      _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _writableState: [Object],
      writable: false,
      allowHalfOpen: false,
      destroyed: true,
      bytesRead: 2962,
      _bytesDispatched: 174,
      _pendingData: null,
      _pendingEncoding: '',
      parser: null,
      _httpMessage: [Object],
      read: [Function],
      _consuming: true,
      write: [Function: writeAfterFIN],
      _idleNext: null,
      _idlePrev: null,
      _idleTimeout: -1 },
   _consuming: true,
   _dumped: false,
   req:
    { domain: null,
      _events: [Object],
      _maxListeners: undefined,
      output: [],
      outputEncodings: [],
      outputCallbacks: [],
      writable: true,
      _last: true,
      chunkedEncoding: false,
      shouldKeepAlive: false,
      useChunkedEncodingByDefault: false,
      sendDate: false,
      _removedHeader: {},
      _hasBody: true,
      _trailer: '',
      finished: true,
      _hangupClose: false,
      _headerSent: true,
      socket: [Object],
      connection: [Object],
      _header: 'GET /signin/passwordless?token=token-id-random-stuff HTTP/1.1\r\nHost: 127.0.0.1:50038\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: node-superagent/1.3.0\r\nConnection: close\r\n\r\n',
      _headers: [Object],
      _headerNames: [Object],
      agent: [Object],
      socketPath: undefined,
      method: 'GET',
      path: '/signin/passwordless?token=token-id-random-stuff',
      parser: null,
      res: [Circular] },
   text: 'Moved Temporarily. Redirecting to http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209',
   read: [Function],
   body: undefined },
request:
 { domain: null,
   _events: { end: [Function] },
   _maxListeners: undefined,
   _agent: false,
   _formData: null,
   method: 'get',
   url: 'http://127.0.0.1:50038/signin/passwordless',
   header: {},
   writable: true,
   _redirects: 1,
   _maxRedirects: 0,
   cookies: '',
   qs: { token: 'token-id-random-stuff' },
   qsRaw: [],
   _redirectList: [],
   _buffer: true,
   app:
    { domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _connections: 0,
      _handle: null,
      _usingSlaves: false,
      _slaves: [],
      allowHalfOpen: true,
      pauseOnConnect: false,
      httpAllowHalfOpen: false,
      timeout: 120000,
      _connectionKey: '4:null:0' },
   _asserts: [],
   _server:
    { domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _connections: 0,
      _handle: null,
      _usingSlaves: false,
      _slaves: [],
      allowHalfOpen: true,
      pauseOnConnect: false,
      httpAllowHalfOpen: false,
      timeout: 120000,
      _connectionKey: '4:null:0' },
   req:
    { domain: null,
      _events: [Object],
      _maxListeners: undefined,
      output: [],
      outputEncodings: [],
      outputCallbacks: [],
      writable: true,
      _last: true,
      chunkedEncoding: false,
      shouldKeepAlive: false,
      useChunkedEncodingByDefault: false,
      sendDate: false,
      _removedHeader: {},
      _hasBody: true,
      _trailer: '',
      finished: true,
      _hangupClose: false,
      _headerSent: true,
      socket: [Object],
      connection: [Object],
      _header: 'GET /signin/passwordless?token=token-id-random-stuff HTTP/1.1\r\nHost: 127.0.0.1:50038\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: node-superagent/1.3.0\r\nConnection: close\r\n\r\n',
      _headers: [Object],
      _headerNames: [Object],
      agent: [Object],
      socketPath: undefined,
      method: 'GET',
      path: '/signin/passwordless?token=token-id-random-stuff',
      parser: null,
      res: [Object] },
   protocol: 'http:',
   host: '127.0.0.1:50038',
   _callback: [Function],
   res:
    { _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      socket: [Object],
      connection: [Object],
      httpVersionMajor: 1,
      httpVersionMinor: 1,
      httpVersion: '1.1',
      complete: false,
      headers: [Object],
      rawHeaders: [Object],
      trailers: {},
      rawTrailers: [],
      _pendings: [],
      _pendingIndex: 0,
      upgrade: false,
      url: '',
      method: null,
      statusCode: 302,
      statusMessage: 'Moved Temporarily',
      client: [Object],
      _consuming: true,
      _dumped: false,
      req: [Object],
      text: 'Moved Temporarily. Redirecting to http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209',
      read: [Function],
      body: undefined },
   response: [Circular],
   _timeout: 0,
   called: true },
req:
 { domain: null,
   _events: { drain: [Function], error: [Function], response: [Function] },
   _maxListeners: undefined,
   output: [],
   outputEncodings: [],
   outputCallbacks: [],
   writable: true,
   _last: true,
   chunkedEncoding: false,
   shouldKeepAlive: false,
   useChunkedEncodingByDefault: false,
   sendDate: false,
   _removedHeader: {},
   _hasBody: true,
   _trailer: '',
   finished: true,
   _hangupClose: false,
   _headerSent: true,
   socket:
    { _connecting: false,
      _hadError: false,
      _handle: null,
      _parent: null,
      _host: '127.0.0.1',
      _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _writableState: [Object],
      writable: false,
      allowHalfOpen: false,
      destroyed: true,
      bytesRead: 2962,
      _bytesDispatched: 174,
      _pendingData: null,
      _pendingEncoding: '',
      parser: null,
      _httpMessage: [Circular],
      read: [Function],
      _consuming: true,
      write: [Function: writeAfterFIN],
      _idleNext: null,
      _idlePrev: null,
      _idleTimeout: -1 },
   connection:
    { _connecting: false,
      _hadError: false,
      _handle: null,
      _parent: null,
      _host: '127.0.0.1',
      _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      _writableState: [Object],
      writable: false,
      allowHalfOpen: false,
      destroyed: true,
      bytesRead: 2962,
      _bytesDispatched: 174,
      _pendingData: null,
      _pendingEncoding: '',
      parser: null,
      _httpMessage: [Circular],
      read: [Function],
      _consuming: true,
      write: [Function: writeAfterFIN],
      _idleNext: null,
      _idlePrev: null,
      _idleTimeout: -1 },
   _header: 'GET /signin/passwordless?token=token-id-random-stuff HTTP/1.1\r\nHost: 127.0.0.1:50038\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: node-superagent/1.3.0\r\nConnection: close\r\n\r\n',
   _headers:
    { host: '127.0.0.1:50038',
      'accept-encoding': 'gzip, deflate',
      'user-agent': 'node-superagent/1.3.0' },
   _headerNames:
    { host: 'Host',
      'accept-encoding': 'Accept-Encoding',
      'user-agent': 'User-Agent' },
   agent:
    { domain: null,
      _events: [Object],
      _maxListeners: undefined,
      defaultPort: 80,
      protocol: 'http:',
      options: [Object],
      requests: {},
      sockets: {},
      freeSockets: {},
      keepAliveMsecs: 1000,
      keepAlive: false,
      maxSockets: Infinity,
      maxFreeSockets: 256 },
   socketPath: undefined,
   method: 'GET',
   path: '/signin/passwordless?token=token-id-random-stuff',
   parser: null,
   res:
    { _readableState: [Object],
      readable: false,
      domain: null,
      _events: [Object],
      _maxListeners: undefined,
      socket: [Object],
      connection: [Object],
      httpVersionMajor: 1,
      httpVersionMinor: 1,
      httpVersion: '1.1',
      complete: false,
      headers: [Object],
      rawHeaders: [Object],
      trailers: {},
      rawTrailers: [],
      _pendings: [],
      _pendingIndex: 0,
      upgrade: false,
      url: '',
      method: null,
      statusCode: 302,
      statusMessage: 'Moved Temporarily',
      client: [Object],
      _consuming: true,
      _dumped: false,
      req: [Circular],
      text: 'Moved Temporarily. Redirecting to http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209',
      read: [Function],
      body: undefined } },
links: {},
text: 'Moved Temporarily. Redirecting to http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209',
body: {},
files: {},
buffered: true,
headers:
 { 'access-control-allow-origin': '*',
   location: 'http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209d',
   vary: 'Accept',
   'content-type': 'text/plain; charset=utf-8',
   'content-length': '1330',
   'set-cookie': [ 'connect.sid=s%3AUVCFCygWVM07fIumPGL0_XpecHnPoK0j.4zBhQbTQyVhVaEanC5lOs4%2FRgdZtJbbqSruZFKJZLf0; Path=/; HttpOnly' ],
   date: 'Thu, 01 Oct 2015 11:44:28 GMT',
   connection: 'close' },
header:
 { 'access-control-allow-origin': '*',
   location: 'http://localhost:9000/callback_popup.html#access_token=cd692b611a0f1da76d5f&token_type=Bearer&expires_in=3600&id_token=eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3QuaXNzdWVyLmNvbSIsInN1YiI6IjZmMzEwYTA3LTlhM2UtNGRiMy04ZDY5LTczOWJhNTg5YTdmZCIsImF1ZCI6IjRhMmMxYTMxLTE1MGQtNDllMy05OTQ2LTI5MDkyMjBjZGIxNiIsImV4cCI6MTQ0MzcwMzQ2OCwiaWF0IjoxNDQzNjk5ODY4LCJub25jZSI6IktHNHZzRDBiZkFqYkVkQ011cm1pUHh6RWNwRkdvZ3VZR1I3YjNjajNBTXMiLCJhdF9oYXNoIjoiOGRkY2UyZTY3ZDFjMzFkZWEwMDQxNmZhMDBkODZiMDUiLCJhbXIiOlsicHdkIl19.uHJAMpgxB-m2GQQXqEkTBSmXfhOq3N3dOai_arMoYBMNvdhFZtigY2MlGNsO5chvvOFiJdgqGyizkTFxano9gqRgnO4k6jPYY0ylGkeZrXvc5-0iCJdm31HK1-D_XBVqfJ9m8rEByenHUJ1ryFWBW3_M4lDWhjaIiTxbkOTAd0H6BNNOllhF_0Cf_gXoZn7KfUCrie8_NJo6uEo6qA7NgEnswFra_8Yr70O6CMVZKJ3p5Q4RUXU6tiGkwnZoPvAUFj2rCsRo2IDJLmgQYWrpcFzU2g4V8y0IyAw6lQchZFgPL2AFrIOIs24BR7uqPtehJOyvIu8UE1cSS80FU3c-6yKJjET2sKu-jQrVGn0nFTt76IftkAES3bkwIWuaOV35MXh6WaVdi9tqp3Y-CP6Ft8PeQOatGGTUMfq-mb_7aztiIodiJvl2bJuGiJwPJClf0k-2_KRWuR6ggUNNWy96JxrjGE1eZoENAdcioNlcOhH1SxuWIb5e9JyaD9EFAfjKCz2j3sEKQHUnfk0zd61e24xjGqcFLSFJ2mRPF6rk16iPydeiRCD1sUstmftCEEEzj_TiqIPtOf8ndWogZCdTJMTxCUpSGg1catIHmm_-lcog0cW7jdS4zliNd7aS_iQp26DnsqUy5WTGpj1L_Yb9oe0c0DU2aRGeQQaUAmzYGXg&session_state=88acacb5372dc314ea69bd13ca45736401756362ce414749b0d403c1faf802d8.4db810700caad69cd1bbebce2455209d',
   vary: 'Accept',
   'content-type': 'text/plain; charset=utf-8',
   'content-length': '1330',
   'set-cookie': [ 'connect.sid=s%3AUVCFCygWVM07fIumPGL0_XpecHnPoK0j.4zBhQbTQyVhVaEanC5lOs4%2FRgdZtJbbqSruZFKJZLf0; Path=/; HttpOnly' ],
   date: 'Thu, 01 Oct 2015 11:44:28 GMT',
   connection: 'close' },
statusCode: 302,
status: 302,
statusType: 3,
info: false,
ok: false,
redirect: true,
clientError: false,
serverError: false,
error: false,
accepted: false,
noContent: false,
badRequest: false,
unauthorized: false,
notAcceptable: false,
forbidden: false,
notFound: false,
charset: 'utf-8',
type: 'text/plain',
setEncoding: [Function],
redirects: [] }
NET 10680: emit close
HTTP 10680: server socket close
it 1 called
    ✓ should consume with the query id
it 2 called
    ✓ should redirect to the callback with the proper tokens
after calls starting


2 passing (2m)

igelmac:connect2 dev$ NODE_DEBUG=net,http:* node_modules/.bin/mocha --timeout 0  --compilers coffee:coffee-script/register ./test/integration/routes/pwless_signin_link.coffee  --reporter spec
```
