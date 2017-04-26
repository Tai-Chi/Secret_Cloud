require 'sinatra'

# Class for route /delete/file
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/file/?' do
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      path = request_body['path']

      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)
      
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fname = pathUnits.pop
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file_by_unit(true, pathUnits, 0)
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
      logger.info "FAILED to delete the folder: #{inspect}"
      status 400
    end
  end
end