class FileSystemSyncAPI < Sinatra::Base
  private
  @filesysList #<Array of Tree>

  public
  def initialize
    super
    @filesysList = []
  end

  def get_tree(uid)
    if @filesysList.at(uid) != nil
      return @filesysList.at(uid)
    else
      return @filesysList[uid] = Tree.new(uid)
    end
  end

  def create_folder(uid, pathUnits, checkDup=false)
    fileExist = false
    state = :trace
    dir = self.get_tree(uid).root_dir.clone
    path = ['']

    pathUnits.each do |fname|
      path.push(fname)
      pid = dir.id
      if state == :trace
        tmp = dir.find_file(fname)
        if tmp != nil
          dir = tmp
        elsif dir.find_file(fname, 1) != nil
          # A file having the same name blocks our route.
          # We should terminate our progress.
          break
        end
      end
      state = :add if state==:trace && tmp==nil
      if state == :add
        # For database
        file = Fileinfo.create(name: fname, parent_id: pid, account_id: uid, portion: 0)
        logger.info "NEW FOLDER CREATED: #{path.join('/')}"
        # For our in-memory tree
        dir.add_file(file)
        dir = file
      end
    end

    if state == :trace
      logger.info 'The folder/file having the same name has already existed.'
      duplicate = true
    else
      duplicate = false
    end
    
    if checkDup
      return duplicate
    else
      return dir
    end
  end
end