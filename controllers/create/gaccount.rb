require 'sinatra'

# Class for route /create/gaccount
class FileSystemSyncAPI < Sinatra::Base
  post '/create/gaccount/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      name = JsonParser.call(request, 'name')
      if name==nil
        logger.info 'gaccount name must be nonempty.'
        status 403
      else
        gaccounts = account.gaccounts
        if gaccounts!=nil
          gaccounts.each do |gaccount|
            if gaccount.name == name
              logger.info 'The gaccount has been created before.'
              halt 403
            end
          end
          CreateGaccount.call(name: name, account_id: account.id)
          logger.info "GACCOUNT CREATED SUCCESSFULLY"
          status 200
        end
      end
    rescue => e
      logger.info "FAILED to create the new account: #{e.inspect}"
      status 400
    end
  end
end
