require 'sinatra'

# Class for route /download
class FileSystemSyncAPI < Sinatra::Base
  post '/download/?' do
    content_type 'application/json'
    begin
      username, path = JsonParser.call(request, 'username', 'path')
      username = username.to_s
      path = path.to_s
      file = self.get_tree(GetAccountID.call(username)).find_file(path, 1)
      # Please note that we now assume all files have only
      # one portion. We must extend this feature to multi-portion
      # version later!
      if file == nil
        logger.info 'The specified file does not exist!!'
        status 403
      else
        puts file.gfid
        logger.info "GET GFID SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to fetch the file info: #{e.inspect}"
      status 400
    end
  end
end