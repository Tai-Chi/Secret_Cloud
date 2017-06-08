require 'sinatra'

# Class for route /delete/account
class FileSystemSyncAPI < Sinatra::Base
  post '/delete/account/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      passwd = JsonParser.call(request, 'passwd')
      passwd = passwd.to_s
      if !account.passwd? passwd
        logger.info 'Such account does not exist!'
        status 403
      elsif !account.passwd? passwd
        logger.info 'Password verification failed!'
        status 403
      else
        self.get_tree(username).root_dir.recur_delete
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