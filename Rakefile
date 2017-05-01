require './app'
require 'rake/testtask'

ENV['RACK_ENV'] = 'test'
puts "Environment: #{ENV['RACK_ENV'] || 'development'}"

task default: [:spec]

desc 'Tests API root route'
task :api_spec => 'db:reset' do
  sh 'ruby specs/api_spec.rb'
end

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  task :spec => 'db:reset'
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task rubo: [:spec] do
  sh 'rubocop app.rb models/*.rb'
end

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
end

namespace :db do
  task :reset_seeds do
    tables = [:schema_seeds, :accounts, :projects,:accounts_projects, :configurations]
    tables.each { |table| DB[table].delete }
  end
  desc 'Seeds the development database'
  task :seed do
    require 'sequel'
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(DB, 'db/seeds')
  end
  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]

  desc 'Perform rollback, migration, and reseed'
  task reset: [:rollback, :migrate, :reseed]
 end
