require 'sinatra'

# Class for route /create/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/create/folder/?' do
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
      path = JSON.parse(request.body.read)['path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      create_folder(uid, tree, pathUnits)

      if @duplicate == false
        status 200
      else
        status 403
      end
    rescue => e
      logger.info "FAILED to create the new folder: #{inspect}"
      status 400
    end
  end
end