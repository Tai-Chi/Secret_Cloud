require 'sinatra'

# API of Backup File System
class FileSystemSyncAPI < Sinatra::Base
  
  configure do
    enable :logging
  end

  get '/?' do
    'File System Synchronization web API'
  end

end