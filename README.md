Title:	MMD-Editor Readme
Author:	Fletcher T. Penney


# Update #

Huh.  I thought I updated this long ago, but obviously not.  This project is left on github as a demonstration.  That said, however, the real project became [MultiMarkdown Composer](http://multimarkdown.com/), which is a commercial application.  MMD Composer 2.0 was a huge rewrite, fixing all the problems that existed with the approach used here in MMD-Edit (which formed the basis for Composer v1.)

You are welcome to use this code, subject to the license.  But I don't recommend it.  There are other applications that have been built with the same approach used here (I'm not saying they used my code).  They seem to suffer from the same problems as this code.  They will eventually figure it out and rewrite, much as I did over a year ago.

There are better ways.  Don't use this.

:)

> Fletcher T. Penney --- 11/22/2013

# MMD-Editor #

This project is a Mac OS X text editor that performs syntax-highlighting for MultiMarkdown documents, as well as implements various features to make authoring and editing MMD documents easier and faster.

It based on work by Ali Rantakari:

<http://hasseg.org/peg-markdown-highlight/>

It uses a PEG grammar based on that from MultiMarkdown (aka [peg-multimarkdown](https://github.com/fletcher/peg-multimarkdown)), which was, in turn, derived from John MacFarlane's [peg-markdown](https://github.com/jgm/peg-markdown).


## Screenshot ##

![screenshot](http://fletcherpenney.net/2011/06/mmd-editor.png)


## Status ##

This is very much a work in progress --- it matches the basic Markdown syntax, and I am adding in support for MMD specific features.

Currently, this app is more "proof of concept" than finished project.  It works well in my tests, but there are a few glitches now and then.

## Features ##

Current Features:

* highlighting almost all of the MMD syntax

* automatically align metadata values

* automatically format basic tables and use tabs for proper alignment

* Use the usual "Bold" and "Italic" commands to insert the appropriate Markdown syntax, e.g. `**foo**` and `*bar*`

* Smart insertion/pairing of "[]", "()", "``", and double quotes

* support for user style sheets in `~/Library/Application Support/MMD-Edit/Styles`

* toggle between MultiMarkdown highlighting and plain Markdown highlighting

* preview HTML if you have MMD 3 installed

* custom default stylesheets based on Ethan Schoonover's solarized theme:  

	<http://ethanschoonover.com/solarized>


Features I would like to see added:


* improved preference pane
	* change colors/fonts/etc
	* change default file extension

* ability to run MMD to export:
	* HTML
	* LaTeX
	* OPML
	* FODT
	* etc

This app will never support as many features/bundles/etc as something like [TextMate](http://macromates.com/), but when combined with something like [TextExpander](http://www.smilesoftware.com/TextExpander/), it can actually be a very useful program for those who use MultiMarkdown.


## Compiling ##

To compile, you must be using Mac OS X, with Developers Tools installed.

from the MMD-Editor directory, type:

	make markdown_parser.c
	cd styleparser
	make

Then open `mmd-editor/mmd-editor.xcodeproj`, change the configuration to "Release | x86_64" in the upper left, and build.


## Contributions ##

I welcome contributions from other developers to help improve this application. Obviously, it has a lot of potential, but there's a long way to go.


## Downloading ##

A compiled (though likely out of date) binary is available for download:

<https://github.com/fletcher/MMD-Editor/downloads>


## Tips for Use ##

* If you want to remove multiple bold/italic spans at once, you can select the entire paragraph, and then add and remove bold and italics.  The act of adding bold removes and bold spans within the selected text (and same for italics).


