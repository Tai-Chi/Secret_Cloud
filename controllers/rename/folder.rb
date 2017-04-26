require 'sinatra'

# Class for route /create/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/rename/folder/?' do
    content_type 'application/json'
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      name = request_body['new_name']
      path = request_body['old_path']

      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)

      file = tree.find_file_by_path(true, path, 0)
      if name == ""
        logger.info 'New name should not be null!!'
        status 403
      elsif file == nil
        logger.info 'The specified folder is not valid!!'
        status 403
      else
        file.name = name
        file.save # This line is very important !!!
        logger.info 'FOLDER RENAMED SUCCESSFULLY'
        status 200
      end
      # Note: We can also detect an action that renames with
      # its original name and return a different status code.
      # Again, this feature is not necessary, so we can do
      # it later.
    rescue => e
      logger.info "FAILED to rename the folder: #{inspect}"
      status 400
    end
  end
end