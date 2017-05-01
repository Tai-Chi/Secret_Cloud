require 'sinatra'

# Class for route /delete/account
class FileSystemSyncAPI < Sinatra::Base
  post '/delete/account/?' do
    content_type 'application/json'
    begin
      username, passwd = JsonParser.call(request, 'username', 'passwd')
      account = Account[name: username]
      if account == nil
        logger.info 'Such account does not exist!'
        status 403
      elsif !account.passwd? passwd
        logger.info 'Password verification failed!'
        status 403
      else
        self.get_tree(GetAccountID.call(username)).root_dir.recur_delete
        account.delete
        logger.info "ACCOUNT DELETED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to delete the account: #{e.inspect}"
      status 400
    end
  end
end