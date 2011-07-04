# MMD-Editor #

This project creates a Mac OS X text editor that performs syntax-highlighting
for MultiMarkdown documents.

It based on work by Ali Rantakari:

<http://hasseg.org/peg-markdown-highlight/>

It uses a PEG grammar based on that from MultiMarkdown (aka
[peg-multimarkdown](https://github.com/fletcher/peg-multimarkdown)), which
was, in turn, derived from John MacFarlane's
[peg-markdown](https://github.com/jgm/peg-markdown).


## Screenshot ##

![screenshot](http://fletcherpenney.net/2011/06/mmd-editor.png)


## Status ##

This is very much a work in progress --- it matches the basic Markdown syntax,
and I am adding in support for MMD specific features. Short of editing the
code, there is no way (yet) to change the colors, fonts, etc.

Currently, this app is more "proof of concept" than finished project. But it
seems to work.

Features I would like to see added:

* support for all MMD syntax

* an innovative way to support tables that simulates [elastic
  tabstops](http://nickgravgaard.com/elastictabstops/) to make tables look
  better

* Preference pane with the ability to:
	* change colors/fonts/etc
	* change default file extension

* built-in support for HTML preview and ability to run MMD to export:
	* HTML
	* LaTeX
	* OPML
	* FODT
	* etc

This app will never support as many features/bundles/etc as something like
[TextMate](http://macromates.com/), but when combined with something like
[TextExpander](http://www.smilesoftware.com/TextExpander/), it can actually be
a very useful program for those who use MultiMarkdown.


## Compiling ##

To compile, you must be using Mac OS X, with Developers Tools installed.

from the MMD-Editor directory, type:

	make markdown_parser.c

Then open `mmd-editor/mmd-editor.xcodeproj`, change the configuration to
"Release | x86_64" in the upper left, and build.


## Contributions ##

I welcome contributions from other developers to help improve this
application. Obviously, it has a lot of potential, but there's a long way to
go.
