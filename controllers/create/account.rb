require 'sinatra'

# Class for route /create/account
class FileSystemSyncAPI < Sinatra::Base
  post '/create/account/?' do
    content_type 'application/json'
    begin
      username, email, passwd = JsonParser.call(request, 'username', 'email', 'passwd')
      username = username.to_s
      email = email.to_s
      passwd = passwd.to_s
      if( username==nil || email==nil || passwd==nil )
        logger.info 'username and email and password must be nonempty.'
        status 403
      elsif Account[name: username] != nil
        logger.info 'The account has been created before.'
        status 403
      else
        CreateAccount.call(name: username, email: email, passwd: passwd)
        logger.info "ACCOUNT CREATED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to create the new account: #{e.inspect}"
      status 400
    end
  end
end