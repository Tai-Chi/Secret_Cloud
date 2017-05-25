require 'sinatra'

# Class for route /download/select
class FileSystemSyncAPI < Sinatra::Base
  post '/download/select/?' do
    content_type 'application/json'
    begin
      username, src_path, dst_path = JsonParser.call(request, 'username', 'src_path', 'dst_path')
      username = username.to_s
      src_path = src_path.to_s
      dst_path = dst_path.to_s
      halt 403, 'This username does not exist!!' if self.get_tree(username) == nil
      self.get_tree(username).dl_queue.push([src_path, dst_path])
      logger.info "PUSH DOWNLOAD INFO SUCCESSFULLY"
      status 200
    rescue => e
      logger.info "FAILED to push the download info: #{e.inspect}"
      status 400
    end
  end
end