require 'sinatra'

# Class for route /create/file
class FileSystemSyncAPI < Sinatra::Base
  post '/create/file/?' do
    content_type 'application/json'
    begin
      request.body.rewind
      uname = JSON.parse(request.body.read)['username']
      uid = Account.where(:name => uname).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, uname)
        @filesysList[uid] = tree
      end
 
      request.body.rewind
      portionNum = Integer(JSON.parse(request.body.read)['portion'])
      
      request.body.rewind
      path = JSON.parse(request.body.read)['path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fName = pathUnits.pop
      
      dir = create_folder(uid, tree, pathUnits)
      if dir.find_file(false, fName, portionNum) == nil
        # For database
        file = Fileinfo.create(name: fName, folder: false, parent_id: dir.id,
        account_id: uid, portion: portionNum)
        # For our in-memory tree
        dir.add_file(file)
        # Here we may also verify that all portions before portionNum
        # must exist as well. However, due to the difficulty, we have
        # not implemented this feature yet.
        logger.info "FILE CREATED SUCCESSFULLY"
        status 200
      else
        logger.info 'The file has already existed.'
        status 403
      end
    rescue => e
      logger.info "FAILED to create the new file: #{inspect}"
      status 400
    end
  end
end