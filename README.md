[![Melpa Status](http://melpa.org/packages/flymake-haml-badge.svg)](https://melpa.org/#/flymake-haml)
[![Melpa Stable Status](http://stable.melpa.org/packages/flymake-haml-badge.svg)](http://stable.melpa.org/#/flymake-haml)
[![Build Status](https://github.com/purcell/flymake-haml/actions/workflows/test.yml/badge.svg)](https://github.com/purcell/flymake-haml/actions/workflows/test.yml)
<a href="https://www.patreon.com/sanityinc"><img alt="Support me" src="https://img.shields.io/badge/Support%20Me-%F0%9F%92%97-ff69b4.svg"></a>

flymake-haml.el
===============

An Emacs flymake handler for syntax-checking HAML source code.

Installation
=============

If you choose not to use one of the convenient packages in
[Melpa][melpa] and [Marmalade][marmalade], you'll need to add the
directory containing `flymake-haml.el` to your `load-path`, and then
`(require 'flymake-haml)`. You'll also need to install
[flymake-easy](https://github.com/purcell/flymake-easy).

Usage
=====

Add the following to your emacs init file:

    (require 'flymake-haml)
    (add-hook 'haml-mode-hook 'flymake-haml-load)

[marmalade]: http://marmalade-repo.org
[melpa]: http://melpa.org

<hr>

[💝 Support this project and my other Open Source work via Patreon](https://www.patreon.com/sanityinc)

[💼 LinkedIn profile](https://uk.linkedin.com/in/stevepurcell)

[✍ sanityinc.com](http://www.sanityinc.com/)

[🐦 @sanityinc](https://twitter.com/sanityinc)
