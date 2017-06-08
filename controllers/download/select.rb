require 'sinatra'

# Class for route /download/select
class FileSystemSyncAPI < Sinatra::Base
  post '/download/select/?' do
    content_type 'application/json'
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      src_path, dst_path = JsonParser.call(request, 'src_path', 'dst_path')
      src_path = src_path.to_s
      dst_path = dst_path.to_s
      self.get_tree(account.name).dl_queue.push([src_path, dst_path])
      logger.info "PUSH DOWNLOAD INFO SUCCESSFULLY"
      status 200
    rescue => e
      logger.info "FAILED to push the download info: #{e.inspect}"
      status 400
    end
  end
end