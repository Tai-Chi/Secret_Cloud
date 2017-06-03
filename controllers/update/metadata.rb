# require 'sinatra'

# # Class for route /create/file
# class FileSystemSyncAPI < Sinatra::Base
#   post '/update/metadata/?' do
#     content_type 'application/json'
#     begin
#       username, file_id, gfile_id, drive_space = JsonParser.call(request, 'username', 'file_id', 'gfile_id', 'drive_space')
#       if username==nil || file_id==nil || gfile_id==nil || drive_space==nil
#         logger.info 'Any parameter cannot be null.'
#         status 403
#       else
#         # Type checking
#         username = username.to_s
#         file_id = Integer(file_id)
#         gfile_id = gfile_id.to_s
#         drive_space = Integer(drive_space)

#         # Body
#         # We must get the file model instance from our tree, or the tree will be outdated.
#         file = self.get_tree(username).get_file_instance(file_id)
#         halt 403, 'The file does not exist!!' if file == nil
#         file.gfid = gfile_id
#         file.save
#         gaccount = Gaccount[file.gaccount_id]
#         gaccount.size = drive_space
#         gaccount.save
#         logger.info "FILE METADATA UPDATED SUCCESSFULLY"
#         status 200
#       end
#     rescue => e
#       logger.info "FAILED to update the file metadata: #{e.inspect}"
#       status 400
#     end
#   end
# end