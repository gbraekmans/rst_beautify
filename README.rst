rst_beautify.sh
===============

Pretty print a reStructuredText file to a column width. This script depends on:

- bash 4.X
- coreutils
- grep

Example
-------

Given this file example.rst:

  .. code:: rst

  This is a really really really really really really really really really really long line of text.

and calling rst_beautify.sh:

  .. code:: bash

  ./rst_beautify.sh example.rst

would print this to the standard output:

  .. code:: rst

  This is a really really really really really really really really really

  really long line of text.

Installation and Usage
----------------------

Install this script by either:

  .. code:: bash

  $ git clone https://github.com/gbraekmans/rst_beautify

or

  .. code:: bash

  $ wget "https://github.com/gbraekmans/rst_beautify/raw/master/rst_beautify.sh"

There's a help function included in the script:

  .. code:: bash

  | $ ./rst_beautify.sh -h
  | rst_beautify.sh [-i] [-h] [-w NUM] FILE
  | Beautifies an rst file to a specified width
  |   -i: Edit file in place
  |   -w: Set width. Default 80
  |   -h: show help

Contributing
------------

I've coded this script after a long day, there might be bugs, typos and
improvements. Please open issues or pull requests!
