require 'sinatra'

# Class for route /create/file
class FileSystemSyncAPI < Sinatra::Base
  post '/create/file/?' do
    content_type 'application/json'
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      path = request_body['path']
      portionNum = Integer(request_body['portion'])
      
      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)
      
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fName = pathUnits.pop
      
      dir = create_folder(uid, tree, pathUnits)[0]
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