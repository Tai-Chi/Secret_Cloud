ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require './init.rb'

include Rack::Test::Methods

def app
  FileSystemSyncAPI
end

