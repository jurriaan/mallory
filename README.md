# mallory

[![Gem Version](https://badge.fury.io/rb/mallory.png)](https://rubygems.org/gems/mallory)
[![Build Status](https://secure.travis-ci.org/odcinek/mallory.png?branch=master)](http://travis-ci.org/odcinek/mallory)
[![Dependency Status](https://gemnasium.com/odcinek/mallory.png?travis)](https://gemnasium.com/odcinek/mallory)
[![Code Climate](https://codeclimate.com/github/odcinek/mallory.png)](https://codeclimate.com/github/odcinek/mallory)

Man-in-the-middle http/https transparent http (CONNECT) proxy over bunch of (unreliable) backends.
It is intended to be used for running test suits / scrapers. It basically shields the proxied application from low responsiveness / poor reliability of underlying proxies.

Proxy list is provided by external backend (ActiveRecord model, Redis set) and is refreshed periodically. Original use case involves separate proxy-gathering daemon (out of the scope of this project).

For the mallory to work properly client certificate validation needs to be turned off.

## Usage

### Command line

```bash
./keys/keygen.sh
bundle exec ./bin/mallory -v -l 9999 #default (no proxy backend, direct requests)
bundle exec ./bin/mallory -v -b file://proxies.txt -l 9999 #start with proxy file
bundle exec ./bin/mallory -v -b redis://127.0.0.1:6379 -l 9999 #start with Redis backend
```

```bash
curl --insecure --proxy 127.0.0.1:9999 https://www.dropbox.com/login
phantomjs --debug=yes --ignore-ssl-errors=yes --ssl-protocol=sslv2 --proxy=127.0.0.1:9999 --proxy-type=http hello.js
```

### Interface

```ruby
mb = Mallory::Backend::File.new('proxies.txt')
mp = Mallory::Proxy.new()
mp.backend = mb
mp.start!
```

### Proxy backends

#### Self

Just direct requests, no proxies, default

#### File

Text file, one http proxy per line, in ```proxy:port``` format.

#### Redis

Redis key TODO

## What mallory is not
- General purpose proxying daemon
- General purpose proxy load balancer
- Anything general purpose really
- For mature general purpose mitm solution (in Python) see [mitmproxy](https://github.com/mitmproxy/mitmproxy)

## TODO
- CA support
- SOCKS5 backends (mixing http and SOCKS5 proxies)
- parallel requests
- even better response reliability

## Resources

- [HTTP Connect Tunneling](http://en.wikipedia.org/wiki/HTTP_tunnel#HTTP_CONNECT_Tunneling)
- [RFC2817, Upgrading to TLS Within HTTP/1.1](http://www.ietf.org/rfc/rfc2817.txt)

## Contributors

- [Marcin Sawicki](https://github.com/odcinek)
- [Maria Kacik](https://github.com/mkacik)
