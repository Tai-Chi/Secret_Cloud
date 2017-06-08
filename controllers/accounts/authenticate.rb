require 'sinatra'

# Class for route /accounts/authenticate
class FileSystemSyncAPI < Sinatra::Base
  post '/accounts/authenticate' do
    content_type 'application/json'
    begin
      credentials = JSON.parse(request.body.read, :symbolize_names => true)
      authenticated = AuthenticateAccount.call(credentials)
    rescue => e
      logger.info "Cannot authenticate #{credentials['username']}: #{e}"
      halt 500
    end
    authenticated ? authenticated.to_json : status(403)
  end
end
