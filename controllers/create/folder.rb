require 'sinatra'

# Class for route /create/folder
class FileSystemSyncAPI < Sinatra::Base
  post '/create/folder/?' do
    content_type 'application/json'
    begin
      request_body = JSON.parse(request.body.read)
      uname = request_body['username']
      path = request_body['path']

      uid = Account.where(:name => uname).first.id
      tree = get_tree(uid, uname)
      
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      duplicate = create_folder(uid, tree, pathUnits)[1]

      if duplicate == false
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