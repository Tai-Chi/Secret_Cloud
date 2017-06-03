require 'sinatra'

class FileSystemSyncAPI < Sinatra::Base
  post '/update/gfid/?' do
    content_type 'application/json'
    begin
      username, file_id, gfile_id = JsonParser.call(request, 'username', 'file_id', 'gfile_id')
      if username==nil || file_id==nil || gfile_id==nil
        logger.info 'Any parameter cannot be null.'
        status 403
      else
        # Type checking
        username = username.to_s
        file_id = Integer(file_id)
        gfile_id = gfile_id.to_s

        # Body
        file = self.get_tree(username).get_file_instance(file_id)
        halt 403, 'This file does not exist!!!' if file == nil
        file.gfid = gfile_id
        file.save
        logger.info "GOOGLE FILE ID UPDATED SUCCESSFULLY"
        status 200
      end
    rescue => e
      logger.info "FAILED to update the file metadata: #{e.inspect}"
      status 400
    end
  end
end