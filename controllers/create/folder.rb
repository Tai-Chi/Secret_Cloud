require 'sinatra'

# Class for route /create/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/create/folder/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      path = JsonParser.call(request, 'path')
      # Type checking
      path = path.to_s
      # Check existing folder
      if self.create_folder(account.id, SplitPath.call(path))[1] == :trace
        logger.info 'The folder has already existed.'
        status 403
      else
        logger.info "FOLDER CREATED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to create the new folder: #{e.inspect}"
      status 400
    end
  end
end