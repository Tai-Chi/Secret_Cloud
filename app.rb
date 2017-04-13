require 'sinatra'
require 'json'
require 'base64'
require_relative 'config/environments'
require_relative 'models/init'


# Configuration of Service to Backup File System
class FileSystemSyncAPI < Sinatra::Base
  private
  @filesysList #<Array of Tree>

  public
  def initialize
    super
    @filesysList = []
  end

  configure do
    enable :logging
    #Configuration.setup
  end

  def create_folder(uid, tree, pathUnits)
    state = :trace
    dir = tree.root_dir.clone
    path = ['']

    pathUnits.each do |fname|
      path.push(fname)
      pid = dir.id
      if state == :trace
        tmp = dir.find_file(true, fname)
        dir = tmp if tmp != nil
      end

      state = :add if state==:trace && tmp==nil
      if state == :add
        # For database
        file = Tfile.create(name: fname, folder: true,parent_id: pid, user_id: uid)
        logger.info "NEW FOLDER CREATED: #{path.join('/')}"
        # For our in-memory tree
        dir.add_file(file)
        dir = file
      end
    end
    dir
  end

  get '/?' do
    'File System Synchronization web API'
  end

  get '/users/?' do
    content_type 'application/json'
    output = { name: User.select(:name, :id).all }
    JSON.pretty_generate(output)
  end
 
  post '/:uname/create/folder/?' do
    content_type 'application/json'
    begin
      uid = User.where(:name => params[:uname]).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, params[:uname])
        @filesysList[uid] = tree
      end

      path = JSON.parse(request.body.read)['path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      create_folder(uid, tree, pathUnits)

      status 200
    rescue => e
      logger.info "FAILED to create the new folder: #{inspect}"
      status 400
    end
  end

  post '/:uname/create/file/?' do
    content_type 'application/json'
    begin
      uid = User.where("name = #{params[:uname]}").select(:id).first
      if @filesysList[uid] != NIL
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, params[:uname])
        @filesysList[uid] = tree
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

  post '/:uname/delete/?' do
    content_type 'application/json'
    begin
      uid = User.where("name = #{params[:uname]}").select(:id).first
      if @filesysList[uid] != NIL
        tree = @filesysList[uid]
      else
        tree = Tree.new(uid, params[:uname])
        @filesysList[uid] = tree
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
