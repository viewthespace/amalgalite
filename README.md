## Amalgalite

* [Homepage](http://github.com/copiousfreetime/amalgalite)
* email jeremy at copiousfreetime dot org
* `git clone git://github.com/copiousfreetime/amalgalite.git`
* [Github](http://github.com/copiousfreetime/amalgalite/)
* [Bug Tracking](http://github.com/copiousfreetime/amalgalite/issues)

## Articles

*  [Writing SQL Functions in Ruby](http://copiousfreetime.org/articles/2009/01/10/writing-sql-functions-in-ruby.html)

## INSTALL

* `gem install amalgalite`

## DESCRIPTION

Amalgalite embeds the SQLite database engine in a ruby extension.  There is no
need to install SQLite separately.  

Look in the examples/ directory to see

* general usage
* blob io
* schema information
* custom functions
* custom aggregates
* requiring ruby code from a database
* full text search

Also Scroll through Amalgalite::Database for a quick example, and a general
overview of the API.

Amalgalite adds in the following additional non-default SQLite extensions:

* [R*Tree index extension](http://sqlite.org/rtree.html)
* [Full Text Search](http://sqlite.org/fts3.html)

## CREDITS

* Jamis Buck for the first [ruby sqlite implementation](http://www.rubyforge.org/projects/sqlite-ruby)

## CHANGES

Read the HISTORY.rdoc file.

## LICENSE

Copyright (c) 2008 Jeremy Hinegardner

All rights reserved.

See LICENSE and/or COPYING for details.
