require 'sinatra'

# Class for route: /users/
class FileSystemSyncAPI < Sinatra::Base
  get '/users/?' do
    content_type 'application/json'
    output = { name: User.select(:name, :id).all }
    JSON.pretty_generate(output)
  end
end