require 'sinatra'

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
        file = Fileinfo.create(name: fname, folder: true, parent_id: pid, user_id: uid, portion: 0)
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
end