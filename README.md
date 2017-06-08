Lurch4Adium
===========

[![Flattr this](https://button.flattr.com/flattr-badge-large.png)](https://flattr.com/submit/auto?fid=mr05q0&url=https%3A%2F%2Fgithub.com%2Fshtrom%2FLurch4Adium)

An attempt at bringing [OMEMO] to [Adium]. This is just a packaging effort.
All credit goes to Richard Bayerle [gkdr] for writing the actual functionality.

This project packages gkdr's [lurch] and [carbons] plugins for
[Pidgin]/[libpurple] as an Adium Xtra, so we can finaly have low-friction
multi-device federated conversations.

The plugin boilerplate comes from the Adium Tutorial [adium-plugin-tutorial],
which still seems to be relevant as of Sierra (10.12.4)/Xcode 8.3.2. One
notable difference, is, however, that libpurple plugins need to use the
`AdiumLibpurplePlugin` wrapper extension, so the `installLibpurplePlugin` and
`loadLibpurplePlugin` methods of the `AILibpurplePlugin` class are called.

Requirements
------------

### HomeBrew [Homebrew]

Easily installed this way, if you like risk [curlpipesh].

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

You can then install a few development tools.

    brew install mercurial cmake

### Xcode

The GUI tools are needed. You can get them from the AppStore [xcode-appstore]
after having sold your soul and given banking details. Apart from that, it's
free-as-in-beer.

You then need to agree to lease out your first born as a receptacle for Steve
Jobs' soul. This is done as follows.

    sudo xcodebuild -license

Building
--------

    make

Will fetch the necessary third-party sources, and build them.

Installation
------------

Once the build has compeleted, you can open the Xtra, which will be sent to
Adium for installation.

    open build/Release/Lurch4Adium.AdiumPlugin

You then need to restart Adium, and make sure this new _Plugin_ is enabled in
the _Xtras manager_.

Usage
-----

You should be able to enable carbons for a Jabber account
by entering

    /carbons on

in any chat window to enable carbons for this account.

You should similarly be able to interact with lurch and enable OMEMO through
the `lurch` command. See

    /lurch help

for more details.


[OMEMO]: https://conversations.im/omemo/
[Adium]: https://adium.im/
[gkdr]: https://github.com/gkdr/
[lurch]: https://github.com/gkdr/lurch
[carbons]: https://github.com/gkdr/carbons
[Pidgin]: https://www.pidgin.im/
[libpurple]: https://developer.pidgin.im/wiki/WhatIsLibpurple
[adium-plugin-tutorial]: https://trac.adium.im/wiki/CreatingPlugins
[homebrew]: https://brew.sh
[curlpipesh]: https://curlpipesh.tumblr.com
[xcode-appstore]: https://itunes.apple.com/au/app/xcode/id497799835?mt=12
