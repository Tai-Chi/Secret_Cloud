require 'sinatra'

# Class for route /delete/file
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/file/?' do
    begin
      username, path = JsonParser.call(request, 'username', 'path')
      username = String.try_convert(username)
      path = String.try_convert(path)
      tree = self.get_tree(GetAccountID.call(username))
      pathUnits, fname = SplitPath.call(path, true)
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file(pathUnits)
      if pdir == nil
        logger.info 'The specified file does not exist!!'
        status 403
      else
        if pdir.delete_file(fname)
          logger.info 'DELETE FILE SUCCESSFULLY'
          status 200
        else
          logger.info 'The specified file does not exist!!'
          status 403
        end
      end
    rescue => e
      logger.info "FAILED to delete the file: #{e.inspect}"
      status 400
    end
  end
end