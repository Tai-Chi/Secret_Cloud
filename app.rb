require 'sinatra'
require 'json'
require 'base64'
require_relative 'config/environments'
require_relative 'models/init'


# Configuration of Service to Backup File System
class FileSystemSyncAPI < Sinatra::Base
  private
  @filesysList #<Array of Tree>
  @duplicate   #<Boolean>

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
    fileExist = false
    state = :trace
    dir = tree.root_dir.clone
    path = ['']
    pathUnits.each do |fname|
      path.push(fname)
      pid = dir.id
      if state == :trace
        tmp = dir.find_file(true, fname, 0)
        if tmp != nil
          dir = tmp
        elsif dir.find_file(false, fname, 1) != nil
          # A folder/file having the same name blocks our route.
          # We should terminate our progress.
          break
        end
      end

      state = :add if state==:trace && tmp==nil
      if state == :add
        # For database
        file = Tfile.create(name: fname, folder: true, parent_id: pid, user_id: uid, portion: 0)
        logger.info "NEW FOLDER CREATED: #{path.join('/')}"
        # For our in-memory tree
        dir.add_file(file)
        dir = file
      end
    end
    if state == :trace
      logger.info 'The folder/file having the same name has already existed.'
      @duplicate = true
    else
      @duplicate = false
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
 
  post '/create/folder/?' do
    content_type 'application/json'
    begin
      request.body.rewind
      uname = JSON.parse(request.body.read)['username']
      uid = User.where(:name => uname).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, uname)
        @filesysList[uid] = tree
      end
      
      request.body.rewind
      path = JSON.parse(request.body.read)['path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      create_folder(uid, tree, pathUnits)

      if @duplicate == false
        status 200
      else
        status 403
      end
    rescue => e
      logger.info "FAILED to create the new folder: #{inspect}"
      status 400
    end
  end

  post '/create/file/?' do
    content_type 'application/json'
    begin
      request.body.rewind
      uname = JSON.parse(request.body.read)['username']
      uid = User.where(:name => uname).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, uname)
        @filesysList[uid] = tree
      end
 
      request.body.rewind
      portionNum = Integer(JSON.parse(request.body.read)['portion'])
      
      request.body.rewind
      path = JSON.parse(request.body.read)['path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fName = pathUnits.pop
      
      dir = create_folder(uid, tree, pathUnits)
      if dir.find_file(false, fName, portionNum) == nil
        # For database
        file = Tfile.create(name: fName, folder: false, parent_id: dir.id,
        user_id: uid, portion: portionNum)
        # For our in-memory tree
        dir.add_file(file)
        # Here we may also verify that all portions before portionNum
        # must exist as well. However, due to the difficulty, we have
        # not implemented this feature yet.
        logger.info "FILE CREATED SUCCESSFULLY"
        status 200
      else
        logger.info 'The file has already existed.'
        status 403
      end
    rescue => e
      logger.info "FAILED to create the new file: #{inspect}"
      status 400
    end
  end
=begin
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
=end

  post '/rename/folder/?' do
    content_type 'application/json'
    begin
      request.body.rewind
      uname = JSON.parse(request.body.read)['username']
      uid = User.where(:name => uname).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, uname)
        @filesysList[uid] = tree
      end

      request.body.rewind
      name = JSON.parse(request.body.read)['new_name']
      request.body.rewind
      path = JSON.parse(request.body.read)['old_path']

      file = tree.find_file_by_path(true, path, 0)
      if name == ""
        logger.info 'New name should not be null!!'
        status 403
      elsif file == nil
        logger.info 'The specified folder is not valid!!'
        status 403
      else
        file.name = name
        file.save # This line is very important !!!
        logger.info 'FOLDER RENAMED SUCCESSFULLY'
        status 200
      end
      # Note: We can also detect an action that renames with
      # its original name and return a different status code.
      # Again, this feature is not necessary, so we can do
      # it later.
    rescue => e
      logger.info "FAILED to rename the folder: #{inspect}"
      status 400
    end
  end

  post '/rename/file/?' do
    content_type 'application/json'
    begin
      request.body.rewind
      uname = JSON.parse(request.body.read)['username']
      uid = User.where(:name => uname).first.id

      if @filesysList[uid] != nil
        tree = @filesysList.at(uid)
      else
        tree = Tree.new(uid, uname)
        @filesysList[uid] = tree
      end
      
      request.body.rewind
      name = JSON.parse(request.body.read)['new_name']
      request.body.rewind
      path = JSON.parse(request.body.read)['old_path']
      pathUnits = path.split(/[\\\/]/)
      pathUnits.select! { |unit| !unit.empty? }
      fName = pathUnits.pop
      dir = tree.find_file_by_unit(true, pathUnits, 0);
      
      if dir == nil
        logger.info 'The specified file does not exist!!'
        status 403
      elsif fName == nil
        logger.info 'New name should not be null!!'
        status 403
      else
        start = true
        portion = 1
        loop do # do-while loop
          file = dir.find_file(false, fName, portion)
          if file != nil
            file.name = fName
            file.save # This line is very important !!!
            logger.info 'FILE RENAMED SUCCESSFULLY'
            status 200
          elsif start
            logger.info 'The specified file does not exist!!'
            status 403
          end
          start = false
          portion += 1
          break unless file != nil
        end
      end
    rescue => e
      logger.info "FAILED to rename the file: #{inspect}"
      status 400
    end
  end

end