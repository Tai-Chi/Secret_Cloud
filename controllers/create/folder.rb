require 'sinatra'

# Class for route /create/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/create/folder/?' do
    content_type 'application/json'
    begin
      username, path = JsonParser.call(request, 'username', 'path')
      # Type checking
      username = String.try_convert(username)
      path = String.try_convert(path)
      # Check existing folder
      if self.create_folder(GetAccountID.call(username), SplitPath.call(path))[1] == :trace
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