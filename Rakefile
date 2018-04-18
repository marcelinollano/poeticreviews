require 'rubygems'
require 'securerandom'
require 'fileutils'

desc('Populate the database')
task(:populate) do
  begin
    `bundle exec ./bin/seed`
  rescue Errno::ENOENT
    puts '=====> Something went wrong'
  end
end

desc('Resets the database')
task(:reset) do
  begin
    File.delete('db/db.sqlite3')
    puts '=====> The database was reseted'
  rescue Errno::ENOENT
    puts '=====> Nothing to reset'
  end
end
