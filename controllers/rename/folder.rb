require 'sinatra'

# Class for route /rename/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/rename/folder/?' do
    content_type 'application/json'
    begin
      username, old_path, new_name = JsonParser.call(request, 'username', 'old_path', 'new_name')
      username = username.to_s
      old_path = old_path.to_s
      new_name = new_name.to_s
      file = self.get_tree(GetAccountID.call(username)).find_file(old_path)
      if new_name == ''
        logger.info 'New name should not be null!!'
        status 403
      elsif file == nil
        logger.info 'The specified folder is not valid!!'
        status 403
      else
        file.name = new_name
        file.save # This line is very important !!!
        logger.info 'FOLDER RENAMED SUCCESSFULLY'
        status 200
      end
      # Note: We can also detect an action that renames with
      # its original name and return a different status code.
      # Again, this feature is not necessary, so we can do
      # it later.
    rescue => e
      logger.info "FAILED to rename the folder: #{e.inspect}"
      status 400
    end
  end
end