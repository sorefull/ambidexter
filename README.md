# Ambidexter

Gem for testing network readiness for HTML stuff.

It is diploma project, so I'm gonna build Rome in one day, actually in 7 like a god, joke it has been developed since [2007](https://github.com/mojombo/god/graphs/contributors).

## Installation

Current version `v0.0.6` is working, seriously.

On Ubuntu, the [curb](https://github.com/taf2/curb) dependencies can be satisfied by installing the following packages:

```bash
sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev
```
Then just symply install it

`gem install ambidexter`

## Usage

Firstly run server by executing `ambidexter server`, it will ask you for port number to start, uses `5899` if skip.

Then run client `ambidexter client`, it will ask you for an IP address of server ('localhost' if skip), it's PORT ('5899' if skip), threads and iterations counters ('1' each one if just enter). If you see green dots FU*K YEAH, it works, for me too. In the end of executing it will print time for each command, sure I'll find more UI way, not today.

## Contributing

HELP ME, seriously, deadline is coming

![coming](http://m.memegen.com/trbzeb.jpg)
