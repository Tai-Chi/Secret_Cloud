require 'sinatra'

# Class for route /create/file
class FileSystemSyncAPI < Sinatra::Base
  post '/create/file/?' do
    content_type 'application/json'
    begin
      username, path, portion = JsonParser.call(request, 'username', 'path', 'portion')
      if portion == nil
        logger.info "Portion cannot be null."
        status 403
      else
        uid = GetAccountID.call(username)
        pathUnits, fName = SplitPath.call(path, true)
        dir, state = self.create_folder(uid, pathUnits)
        if state == :blocked
          logger.info "There may be some files blocking our route..."
          status 403
        elsif dir == nil
          logger.info "The path is not valid."
          status 403
        elsif dir.find_file(fName, portion) == nil
          # For database
          file = Fileinfo.create(name: fName, parent_id: dir.id, account_id: uid, portion: portion)
          # For our in-memory tree
          dir.add_file(file)
          # Here we may also verify that all portions before portion(Num)
          # must exist as well. However, due to the difficulty, we have
          # not implemented this feature yet.
          logger.info "FILE CREATED SUCCESSFULLY"
          status 200
        else
          logger.info 'The file has already existed.'
          status 403
        end
      end
    rescue => e
      logger.info "FAILED to create the new file: #{e.inspect}"
      status 400
    end
  end
end