Lurch4Adium
===========

An attempt at bringing [OMEMO] to [Adium].

tl;dr: This is an early work in progress. It just doesn't work at the moment.

This project packages gkdr's [lurch] and [carbons] plugins for [Pidgin]/[libpurple] as
an Adium Xtra, so we can finaly have low-friction multi-device federated
conversations.

The plugin boilerplate comes from the Adium Tutorial [adium-plugin-tutorial],
which still seems to be relevant as of Sierra (10.12.4)/Xcode 8.3.2.

Building
--------

    make

Will fetch the necessary third-party sources, and build them. That's it for now.

[OMEMO]: https://conversations.im/omemo/
[Adium]: https://adium.im/
[lurch]: https://github.com/gkdr/lurch
[carbons]: https://github.com/gkdr/carbons
[Pidgin]: https://www.pidgin.im/
[libpurple]: https://developer.pidgin.im/wiki/WhatIsLibpurple
[adium-plugin-tutorial]: https://trac.adium.im/wiki/CreatingPlugins
