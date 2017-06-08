require 'sinatra'

# Class for route /create/file
class FileSystemSyncAPI < Sinatra::Base
  post '/create/file/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      path, portion, size = JsonParser.call(request, 'path', 'portion', 'size')
      if path==nil || portion==nil || size==nil
        logger.info "Any parameter cannot be null."
        status 403
      else
        # Type checking
        path = path.to_s
        portion = Integer(portion)
        # gfid = gfid.to_s
        size = Integer(size)

        # Body
        uid = account.id
        pathUnits, fName = SplitPath.call(path, true)
        dir, state = self.create_folder(uid, pathUnits)
        if state == :blocked
          logger.info "There may be some files blocking our route..."
          status 403
        elsif dir == nil
          logger.info "The path is not valid."
          status 403
        elsif dir.find_file(fName, portion) == nil
          # Find available google drive for this file
          gaccount = AllocateDriveSpace.call(size)
          halt 403, 'There is no available drive!!' if gaccount == nil
          # For database
          file = CreateFileinfo.call(name: fName, parent_id: dir.id, account_id: uid, portion: portion, gaccount_id: gaccount[:id], size: size)
          # For our in-memory tree
          dir.add_file(file)
          # Return fileinfo id and assigned gaccount
          body file.id.to_s + ' ' + gaccount.name
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