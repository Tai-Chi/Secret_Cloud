require 'sinatra'

# Class for route /password
class FileSystemSyncAPI < Sinatra::Base
  post '/password/?' do
    content_type 'application/json'
    begin
      username, old_passwd, new_passwd = JsonParser.call(request, 'username', 'old_passwd', 'new_passwd')
      username = username.to_s
      old_passwd = old_passwd.to_s
      new_passwd = new_passwd.to_s
      account = Account[name: username]
      if account == nil
        logger.info 'Such account does not exist!'
        status 403
      elsif !account.passwd? old_passwd
        logger.info 'Password verification failed!'
        status 403
      elsif new_passwd==nil || new_passwd==''
        logger.info 'Password cannot be empty!'
        status 403
      else
        account.passwd = new_passwd
        account.save
        logger.info "PASSWORD RESET SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to change the password: #{e.inspect}"
      status 400
    end
  end
end