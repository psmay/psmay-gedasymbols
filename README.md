# psmay : gEDA Symbols

## Synopsis

These are materials created for use with [gEDA]. The directory structure is
consistent with a user directory on [gedasymbols.org] in the event that at any
point I ask for and am granted a CVS account there. (Somehow, apparently people
are still using CVS.) I prefer bzr and am tolerant of git, so I'll be
maintaining my gEDA stuff elsewhere for the time being.

  [gEDA]: http://www.geda-project.org/
  [gedasymbols.org]: http://www.gedasymbols.org/

## Usage

### Per-project

When including symbols or footprints in a project, be sure either to embed
them or to include them in a project-local resource directory (i.e., as you
would with anything from gedasymbols).

If you're wondering how to do this, just follow the example of any given major
gEDA project on Github. There are multiple different styles to choose from; a
very simple one is that used by the project for [RepRap Generation 7
Electronics] and goes something like this:

* Add a `packages` directory at the top level of the project.
* Toss all footprints and symbols into that directory.
* PCB automatically includes a dir named `packages` into the library.
* To get `gschem` to recognize it, create `gafrc` at the top level and add the
  line `(component-library "./packages")`.

Some projects prefer to use a directory called `sym` or `symbols` for the
symbols. This only affects the `gafrc` line (substitude the directory name for
`packages`).

  [RepRap Generation 7 Electronics]: https://github.com/Traumflug/Generation_7_Electronics

### Globally (if you're me or a big fan)

These are the instructions I follow to make everything appear by default.

These instructions assume a working copy of this branch is at

	/some-path/psmay-gedasymbols

Substitute the actual location as necessary. Absolute paths should be used
unless the usage is project-specific.

#### gschem

To `~/.gEDA/gafrc`, add:

	(component-library-search "/some-path/psmay-gedasymbols/symbols" "~psmay")

#### pcb

In preferences, under Library, add

	/some-path/psmay-gedasymbols/footprints

to the Element Directories. This is a `:`-delimited list, so add a delimiter if
necessary.

(This is also the `library-newlib` setting in `~/.pcb/preferences`.)

#### gsch2pcb

Footprints are only mapped from the `footprint` attributes in a schematic if
the `elements-dir` has been added to the project.

To the project `*.gsch2pcb` file, add:

	elements-dir /some-path/psmay-gedasymbols/footprints

## Terms

Files are licensed as marked; in particular, some files in the `tools`
directory are under GNU GPL v2+, and some non-generated symbols and footprints
may indicate their own licenses.

If no license is indicated for a file in this repository, the contents of the
file are subject to the terms of the MIT License (the OSI-approved version),
which reads thus:

> Copyright © 2013-2014 Peter S. May
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
