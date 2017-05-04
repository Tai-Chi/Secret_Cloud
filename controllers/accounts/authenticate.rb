require 'sinatra'

# Class for route /accounts/authenticate
class FileSystemSyncAPI < Sinatra::Base
  post '/accounts/authenticate' do
    content_type 'application/json'
    begin
      credentials = JSON.parse(request.body.read)
      pass = AuthenticateAccount.call(credentials)
    rescue => e
      logger.info "Cannot authenticate #{credentials['username']}: #{e}"
      halt 500
    end
    pass ? status(200) : status(403)
  end
end
