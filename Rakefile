require 'rake/testtask'
require './init.rb'

ENV['RACK_ENV'] ||= 'development'
# puts "Environment: #{ENV['RACK_ENV'] || 'development'}"

task default: [:spec]

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  task :spec => 'db:treset'
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task rubo: [:spec] do
  sh 'rubocop app.rb models/*.rb'
end

namespace :crypto do
  desc 'Create sample cryptographic key for database'
  task :db_key do
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
end

namespace :db do
  require 'sequel'
  Sequel.extension :migration

  desc 'Run migrations'
  task :tmigrate do
    system 'RACK_ENV=test rake db:migrate'
  end
  task :migrate do
    puts "Migrating database to latest in \"#{ENV['RACK_ENV']}\" environment"
    Sequel::Migrator.run(DB, 'db/migrations')
  end

  desc 'Rollback database to specified target'
  # e.g. $ rake db:rollback[100]
  task :trollback do
    str = ARGV[0].split(/[\[\]]/)[1]
    system "RACK_ENV=test rake db:rollback[#{str}]"
  end
  task :rollback, [:target] do |_, args|
    target = args[:target] ? args[:target] : 0
    target = Integer(target)
    puts "Rolling back database to #{target}"
    Sequel::Migrator.run(DB, 'db/migrations', target: target)
  end
=begin
  desc 'Perform migration reset (full rollback and migration)'
  task :treset do
    system 'RACK_ENV=test rake db:reset'
  end
  task reset: [:rollback, :migrate]

  desc 'Self-built database'
  task :tselfbuild do
    system "RACK_ENV=test rake db:selfbuild"
  end
  task :selfbuild => [:reset] do
    User.insert(name: 'Alan', passwd: 'Alan')
  end
=end
end

namespace :db do
  task :treset_seeds do
    system 'RACK_ENV=test rake db:reset_seeds'
  end
  task :reset_seeds do
    tables = [ :schema_seeds, :fileinfos, :accounts, :gaccounts]
    tables.each { |table| DB[table].delete if DB.table_exists?(table) }
  end
  desc 'Seeds the development database'
  task :tseed do
    require 'sequel'
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:test)
    Sequel.extension :seed
    Sequel::Seeder.apply(DB, 'db/seeds')
  end
  task :seed do
    require 'sequel'
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(DB, 'db/seeds')
  end
  desc 'Delete all data and reseed'
  task treseed: [:treset_seeds, :tseed]
  task reseed: [:reset_seeds, :seed]

  desc 'Perform rollback, migration, and reseed'
  task treset: [:trollback, :tmigrate, :treseed]
  task reset: [:rollback, :migrate, :reseed]
end
