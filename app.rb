require 'sinatra'
require 'json'
require 'base64'
require_relative 'models/configuration'

# Configuration of Service to Backup File System
class FileSystemSyncAPI < Sinatra::Base
  private:
  @filesysList #<Array of Tree>

  public:
  configure do
    enable :logging
    Configuration.setup
  end

  get '/?' do
    'File System Synchronization web API'
  end

  get '/users/?' do
    content_type 'application/json'
    output = { name: User.all }
    JSON.pretty_generate(output)
  end
=begin
  get '/:name/?' do
    content_type 'text/plain'
    begin
      Base64.strict_decode64 Configuration.find(params[:id]).document
    rescue => e
      status 404
      e.inspect
    end
  end

  get '/:name/create/folder/:path' do
    content_type 'application/json'
    begin
      output = { configuration_id: Configuration.find(params[:id]) }
      JSON.pretty_generate(output)
    rescue =>e
      status 404
      logger.info "FAILED to GET configuration: #{e.inspect}"
    end
  end
=end
 
  def create_folder(tree, pathUnits)
    dir = tree.root_dir.clone
    # check each component of objList to verify
    # that the path is valid
    pathUnits.each do |fname|
      pid = dir.id
      if state=='trace'
        tmp = dir.find_file(false, fname)
        dir = tmp if tmp != NIL
      end
      state = 'add' if state=='trace' && tmp==NIL
      if state=='add'
        # For database
        id = File.insert(:name => fname,
                         :attr => 'folder',
                         :pid => pid,
                         :uid => uid
                        ).returning(:id)
        # For our in-memory tree
        file = File.new(false, fname, id)
        dir.add_file(file)
        dir = file
      end
    end
    return dir
  end
  
  post ':uname/create/folder/?' do
    content_type 'application/json'
    begin
      state = 'trace'
      uid = User.where("name = #{params[:uname]}").select(:id).first
      if @filesysList.at(uid) != NIL
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(params[:uname])
        @filesysList.insert(uid, tree)
      end
      pathUnits = JSON.parse(request.body.read)['path'].split('/\\')
      # if create_folder(tree,pathUnits)=='add'
      create_folder(tree,pathUnits)
        logger.info "NEW FOLDER CREATED: #{path}"
      #else
       # logger.info "The folder #{path} has existed."
      #end
      status 200

      # redirect '/api/v1/configurations/#{new_config.id}.json'
    rescue => e
      logger.info "FAILED to create the new folder: #{inspect}"
      status 400
    end
  end

  post ':uname/create/file/?' do
    content_type 'application/json'
    begin
      uid = User.where("name = #{params[:uname]}").select(:id).first
      if @filesysList.at(uid) != NIL
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(params[:uname])
        @filesysList.insert(uid, tree)
      end
      pathUnits = JSON.parse(request.body.read)['path'].split('/\\')
      portion = JSON.parse(request.body.read)['portion']
      fname = pathUnits.last
      pathUnits.drop!
      folder = create_folder(tree, pathUnits)
      # For database
      id = File.insert(:name => fname,
                       :attr => 'file',
                       :pid => folder.id,
                       :uid => uid,
                       :portion => portion
                      ).returning(:id)
      # For our in-memory tree
      folder.add_file(File.new(true, fname, id))
      logger.info "NEW FILE CREATED: #{path}"
      status 200
    rescue => e
      logger.info "FAILED to create the new file: #{inspect}"
      status 400
    end
  end

  post ':uname/delete/?' do
    content_type 'application/json'
    begin
      uid = User.where("name = #{params[:uname]}").select(:id).first
      if @filesysList.at(uid) != NIL
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(params[:uname])
        @filesysList.insert(uid, tree)
      end
      pathUnits = JSON.parse(request.body.read)['path'].split('/\\')
      fname = pathUnits.last
      pathUnits.drop!
      upfolder = tree.find_file(pathUnits)
      if upfolder == NIL
        logger.info 'The specified path does not exist.'
        status 403
        return
      end
      file = upfolder.find_file(fname)
      if file == NIL
        logger.info 'The specified path does not exist.'
        status 403
        return
      end
      # Question:
      # (1) directly delete the instance make the parent folder know? No.
      # (2) need to go into the parent folder to adjust the parent list? Yes.
      # Delete that folder in our tree.
      upfolder.delete_file(fname)
      # Delete that folder in the database
      File.where("id = #{file.id}").delete

      # log
      logger.info "FILE/FOLDER DELETED SUCCESSFULLY: #{path}"
      status 200
    rescue => e
      logger.info "FAILED to delete the file/folder: #{inspect}"
      status 400
    end
  end

end
