require 'rubygems'
require 'securerandom'
require 'fileutils'

desc('Resets the database')
task(:reset) do
  puts '-----> Running reset task'
  if File.exist?('db/db.sqlite3')
    File.delete('db/db.sqlite3')
    puts '=====> Previous db was deleted'
  end
  system('bin/migrate')
  puts '=====> The db was created'
end
