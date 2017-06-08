ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require './init.rb'

include Rack::Test::Methods

def app
  FileSystemSyncAPI
end

def get_authorized_client(username, passwd)
  browser = Rack::Test::Session.new(Rack::MockSession.new(FileSystemSyncAPI))
  auth = AuthenticateAccount.call(username: username,
                                  passwd: passwd)
  browser.header 'AUTHORIZATION', "Bearer #{auth[:auth_token]}"
  browser.header 'CONTENT_TYPE', 'application/json'
  browser
end
