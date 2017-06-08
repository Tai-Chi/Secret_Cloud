require 'sinatra'

# Class for route /delete/folder
class FileSystemSyncAPI < Sinatra::Base
    post '/delete/folder/?' do
    begin
      account = authenticated_account(env)
      _403_if_not_logged_in(account)
      path = JsonParser.call(request, 'path')
      path = path.to_s
      tree = self.get_tree(account.name)
      pathUnits = SplitPath.call(path)
      pdir = (pathUnits.size <= 1) ? tree.root_dir : tree.find_file(pathUnits[0..-2])
      dir = tree.find_file(pathUnits)
      if dir == nil
        logger.info 'The specified folder does not exist!!'
        status 403
      else
        gaccount_gfid_list = dir.recur_delete
        pdir.list.delete(dir)
        if gaccount_gfid_list == nil || gaccount_gfid_list.size <= 0
          logger.info 'The folder is empty!!'
          status 403
        else
          logger.info 'DELETE FOLDER SUCCESSFULLY'
          logger.info "DELETED Gaccounts/Gfid(s): #{gaccount_gfid_list.join(' ')}"
          body gaccount_gfid_list.join("\n")
          status 200
        end
      end
    rescue => e
      logger.info "FAILED to delete the folder: #{e.inspect}"
      status 400
    end
  end
end