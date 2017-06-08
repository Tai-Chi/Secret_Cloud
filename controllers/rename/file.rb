require 'sinatra'

# Class for route /rename/file
class FileSystemSyncAPI < Sinatra::Base
  post '/rename/file/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      old_path, new_name = JsonParser.call(request, 'old_path', 'new_name')
      old_path = old_path.to_s
      new_name = new_name.to_s
      pathUnits, old_name = SplitPath.call(old_path, true)
      dir = self.get_tree(account.name).find_file(pathUnits)
      if dir == nil
        logger.info 'The specified file does not exist!!'
        status 403
      elsif new_name == nil
        logger.info 'New name should not be null!!'
        status 403
      else
        start = true
        portion = 1
        loop do # do-while loop
          file = dir.find_file(old_name, portion)
          if file != nil
            file.name = new_name
            file.save # This line is very important !!!
            logger.info 'FILE RENAMED SUCCESSFULLY'
            status 200
          elsif start
            logger.info 'The specified file does not exist!!'
            status 403
          end
          start = false
          portion += 1
          break unless file != nil
        end
      end
    rescue => e
      logger.info "FAILED to rename the file: #{e.inspect}"
      status 400
    end
  end
end