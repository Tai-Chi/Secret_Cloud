require 'sinatra'

class FileSystemSyncAPI < Sinatra::Base
  post '/update/space/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      gaccount, space = JsonParser.call(request, 'gaccount', 'space')
      if gaccount==nil || space==nil
        logger.info 'Any parameter cannot be null.'
        status 403
      else
        # Type checking
        gaccount = gaccount.to_s
        space = Integer(space)

        # Body
        halt 403, 'This google account does not exist!!!' unless UpdateDriveSpace.call(gaccount, space)
        logger.info "GOOGLE DRIVE SPACE UPDATED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to update the file metadata: #{e.inspect}"
      status 400
    end
  end
end