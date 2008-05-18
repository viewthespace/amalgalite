#--
# Copyright (c) 2008 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++
require 'amalgalite3'
require 'amalgalite/statement'

module Amalgalite
  class Database

    class InvalidModeError < ::Amalgalite::Error; end
    ##
    # Create a new Amalgalite database
    #
    # :call-seq:
    #   Amalgalite::Database.new( filename, "r", opts = {}) -> Database
    #
    # The first parameter is the filename of the sqlite database.  
    # The second parameter is the standard file modes of how to open a file.
    #
    # The modes are:
    #   * r  - Read-only
    #   * r+ - Read/write, an error is thrown if the database does not already
    #          exist.
    #   * w+ - Read/write, create a new database if it doesn't exist
    #          This is the default as this is how most databases will want
    #          to be utilized.
    #
    # opts is a hash of available options for the database:
    #
    #   :utf16 : option to set the database to a utf16 encoding if creating 
    #            a database. By default, databases are created with an 
    #            encoding of utf8.  Setting this to true and opening an already
    #            existing database has no effect.
    #
    #
    include Amalgalite::SQLite3::Constants
    VALID_MODES = {
      "r"  => Open::READONLY,
      "r+" => Open::READWRITE,
      "w+" => Open::READWRITE | Open::CREATE,
    }

    attr_reader :api

    ##
    # Create a new database 
    #
    def initialize( filename, mode = "w+", opts = {})
      @open = false
      unless VALID_MODES.keys.include?( mode ) 
        raise InvalidModeError, "#{mode} is invalid, must be one of #{VALID_MODES.keys.join(', ')}" 
      end

      if not File.exist?( filename ) and opts[:utf16] then
        @api = Amalgalite::SQLite3::Database.open16( filename )
      else
        @api = Amalgalite::SQLite3::Database.open( filename, VALID_MODES[mode] )
      end
      @open = true
    end

    ##
    # Is the database open or not
    #
    def open?
      @open
    end

    ##
    # Close the database
    #
    def close
      if open? then
        @api.close
      end
    end

    ##
    # Is the database in autocommit mode or not
    #
    def autocommit?
      @api.autocommit?
    end

    ##
    # Return the rowid of the last inserted row
    #
    def last_insert_rowid
      @api.last_insert_rowid
    end

    ##
    # Is the database utf16 or not?  A database is utf16 if the encoding is not
    # UTF-8.  Database can only be UTF-8 or UTF-16, and the default is UTF-8
    #
    def utf16?
      unless @utf16.nil?
        @utf16 = (encoding != "UTF-8") 
      end
      return @utf16
    end

    ## 
    # return the encoding of the database
    #
    def encoding
      unless @encoding
        @encoding = "UTF-8"
        #@encoding = db.pragma( "encoding" )
      end
      return @encoding
    end

    ##
    # Prepare a statement for execution
    #
    # If called with a block, the statement is yielded to the block and the
    # statement is closed when the block is done.
    #
    def prepare( sql )
      stmt = Amalgalite::Statement.new( self, sql )
      if block_given? then
        begin 
          yield stmt
        ensure
          stmt.close
          stmt = nil
        end
      end
      return stmt
    end

    ##
    # Execute a single SQL statement. 
    #
    # If called with a block and there are result rows, then they are iteratively
    # yielded to the block.
    #
    # If no block passed and there are results, then a ResultSet is returned.
    # Otherwise nil is returned.  On an error an exception is thrown.
    #
    # This is just a wrapper around the preparation of an Amalgalite Statement and
    # iterating over the results.
    #
    def execute( sql, *bind_params )
      stmt = prepare( sql )
      stmt.bind( *bind_params )
      if block_given? then
        stmt.each { |row| yield row }
      else
        return stmt.all_rows
      end
    ensure
      stmt.close if stmt
    end

    ##
    # Execute a batch of statements, this will execute all the sql in the given
    # string until no more sql can be found in the string.  It will bind the 
    # same parameters to each statement.  All data that would be returned from 
    # all of the statements is thrown away.
    #
    # All statements to be executed in the batch must be terminated with a ';'
    # Returns the number of statements executed
    #
    #
    def execute_batch( sql, *bind_params) 
      count = 0
      while sql
        prepare( sql ) do |stmt|
          stmt.execute( *bind_params )
          sql =  stmt.remaining_sql 
          sql = nil unless (sql.index(";") and Amalgalite::SQLite3.complete?( sql ))
        end
        count += 1
      end
      return count
    end
  end
end
