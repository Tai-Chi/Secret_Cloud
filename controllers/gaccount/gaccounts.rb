require 'sinatra'

# Class for route: /gaccounts/
class FileSystemSyncAPI < Sinatra::Base
  get '/gaccounts/?' do
    content_type 'application/json'
    account = authenticated_account(env)
    _403_if_not_logged_in(account)
    account.gaccounts.to_json
  end
end
