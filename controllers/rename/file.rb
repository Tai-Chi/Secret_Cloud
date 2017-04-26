require 'sinatra'

# Class for route /rename/file
class FileSystemSyncAPI < Sinatra::Base
  post '/rename/file/?' do
    content_type 'application/json'
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      name = request_body['new_name']
      path = request_body['old_path']

      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)
      
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fName = pathUnits.pop
      dir = tree.find_file_by_unit(true, pathUnits, 0);
      
      if dir == nil
        logger.info 'The specified file does not exist!!'
        status 403
      elsif fName == nil
        logger.info 'New name should not be null!!'
        status 403
      else
        start = true
        portion = 1
        loop do # do-while loop
          file = dir.find_file(false, fName, portion)
          if file != nil
            file.name = fName
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
      logger.info "FAILED to rename the file: #{inspect}"
      status 400
    end
  end
end