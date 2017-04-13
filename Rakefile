require './app'
require 'rake/testtask'

puts "Environment: #{ENV['RACK_ENV'] || 'development'}"

namespace :db do
  require 'sequel'
  Sequel.extension :migration

  desc 'Run migrations'
  task :migrate do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(DB, 'db/migrations')
  end

  desc 'Rollback database to specified target'
  # e.g. $ rake db:rollback[100]
  task :rollback, [:target] do |_, args|
    target = args[:target] ? args[:target] : 0
    puts "Rolling back database to #{target}"
    Sequel::Migrator.run(DB, 'db/migrations', target: target)
  end

  desc 'Perform migration reset (full rollback and migration)'
  task reset: [:rollback, :migrate]

  desc 'Recreate the whole database'
  task :rebuild => :reset do
    User.insert(:name=>'Fxxk', :passwd=>'Fxxk')
  end
end

desc 'Create folder'
task :test => 'db:rebuild' do
  sh 'http POST http://localhost:9292/Fxxk/create/folder/ path=\'/a/b\''
  sh 'http POST http://localhost:9292/Fxxk/create/folder/ path=\'/a//b///c\''
end
