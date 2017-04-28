require 'econfig'
require 'sinatra'

# API of Backup File System
class FileSystemSyncAPI < Sinatra::Base
  extend Econfig::Shortcut

  configure do
    enable :logging

    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureDB.setup(settings.config)
  end

  get '/?' do
    'File System Synchronization web API'
  end

end