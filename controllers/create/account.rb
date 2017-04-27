require 'sinatra'

# Class for route /create/account
class FileSystemSyncAPI < Sinatra::Base
  post '/create/account/?' do
    content_type 'application/json'
    begin
      username, passwd = JsonParser.call(request, 'username', 'passwd')
      if( username==nil || username=='' || passwd==nil || passwd=='' )
        logger.info 'Both username and password must be nonempty.'
        status 403
      elsif Account[name: username] != nil
        logger.info 'The account has been created before.'
        status 403
      else
        Account.create(name: username, passwd: passwd)
        logger.info "ACCOUNT CREATED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to create the new account: #{e.inspect}"
      status 400
    end
  end
end