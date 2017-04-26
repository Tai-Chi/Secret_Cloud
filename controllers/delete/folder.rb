require 'sinatra'

# Class for route /delete/folder
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/folder/?' do
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      path = request_body['path']

      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)
      
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file_by_unit(true, pathUnits[0..-2], 0)
      dir = tree.find_file_by_unit(true, pathUnits, 0)
      if dir == nil
        logger.info 'The specified folder does not exist!!'
        status 403
      else
        dir.recur_delete
        pdir.list.delete(dir)
        logger.info 'DELETE FOLDER SUCCESSFULLY'
        status 200
      end
    rescue => e
      logger.info "FAILED to delete the folder: #{inspect}"
      status 400
    end
  end
end