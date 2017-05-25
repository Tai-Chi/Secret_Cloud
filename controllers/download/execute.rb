require 'sinatra'

# Class for route /download/execute
class FileSystemSyncAPI < Sinatra::Base
  post '/download/execute/?' do
    content_type 'application/json'
    begin
      username = JsonParser.call(request, 'username')
      username = username.to_s
      tree = self.get_tree(username)
      halt 403, 'The username does not exist!!' if tree == nil
      halt 403, 'Nothing to be downloaded' if tree.dl_queue.empty?
      src_path, dst_path = tree.dl_queue.pop
      file = tree.find_file(src_path,1)
      halt 403, 'The file to be downloaded does not exist!!' if file == nil
      body Gaccount[file.gaccount_id].name + ' ' + file.gfid + ' ' + dst_path
      # Please note that we now assume all files have only
      # one portion. We must extend this feature to multi-portion
      # version later!
      logger.info "GET DOWNLOADED FILE INFO SUCCESSFULLY"
      status 200
    rescue => e
      logger.info "FAILED to send the file info: #{e.inspect}"
      status 400
    end
  end
end