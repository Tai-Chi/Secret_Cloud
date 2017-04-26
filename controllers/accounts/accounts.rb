require 'sinatra'

# Class for route: /accounts/
class FileSystemSyncAPI < Sinatra::Base
  get '/accounts/?' do
    content_type 'application/json'
    output = { name: Account.select(:name, :id).all }
    JSON.pretty_generate(output)
  end
end