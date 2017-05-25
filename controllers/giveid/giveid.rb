# require 'sinatra'

# # Class for route /giveid
# class FileSystemSyncAPI < Sinatra::Base
#   post '/giveid/?' do
#     content_type 'application/json'
#     begin
#       username, path, portion, new_id = JsonParser.call(request, 'username', 'path', 'portion', 'new_id')
#       username = String.try_convert(username)
#       path = String.try_convert(path)
#       portion = Integer(portion)
#       new_id = String.try_convert(new_id)
#       if portion == nil || new_id == nil
#         logger.info "Portion or Gfid cannot be null."
#         status 403
#       elsif Integer(portion) == 0
#         logger.info "Portion should be larger than 0."
#         status 403
#       else
#         file = self.get_tree(username).find_file(path, portion)
#         if file == nil
#           logger.info 'The specified file does not exist!!'
#           status 403
#         else
#           file.gfid = new_id
#           file.save
#           logger.info "GFID GIVEN SUCCESSFULLY"
#           status 200
#         end
#       end
#     rescue => e
#       logger.info "FAILED to give the google file id to the file: #{e.inspect}"
#       status 400
#     end
#   end
# end