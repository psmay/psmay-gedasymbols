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

These instructions assume a working copy of this branch is at

	/some-path/psmay-gedasymbols

Substitute the actual location as necessary. Absolute paths should be used
unless the usage is project-specific.

### gschem

To `~/.gEDA/gafrc`, add:

	(component-library "/some-path/psmay-gedasymbols/symbols")

### pcb

In preferences, under Library, add

	/some-path/psmay-gedasymbols/footprints

to the Element Directories. This is a `:`-delimited list, so add a delimiter if
necessary.

(This is also the `library-newlib` setting in `~/.pcb/preferences`.)

### gsch2pcb

Footprints are only mapped from the `footprint` attributes in a schematic if
the `elements-dir` has been added to the project.

To the project `.gsch2pcb` file, add:

	elements-dir /some-path/psmay-gedasymbols/footprints

## Terms

Unless otherwise noted, all files in this repository are subject to the terms
of the MIT License (the OSI version), which reads thus:

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

