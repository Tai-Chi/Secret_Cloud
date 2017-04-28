require 'sequel'

class Tree
  public
  attr_reader :root_dir #<Fileinfo>
  #attr_reader :fList #<Array of Fileinfo>

  # Specify someone's file system
  # How to recover the whole tree from the sql table?
  def initialize(uid)
    fList = []
    ftable = Account[uid].fileinfos
    ftable.each do |file|
      fList[file.id] = file
    end
    ftable.each do |file|
      if file.parent_id == file.id
        @root_dir = file
      else
        fList[file.parent_id].add_file(file)
      end
    end
    if ftable.empty?
      @root_dir = CreateFileinfo.call(name: 'ROOT', account_id: uid, portion: 0)
      @root_dir.parent_id = @root_dir.id
      @root_dir.save
      # fList[@root_dir.id] = @root_dir
    end
  end

  # def find_file_by_path(folder, path, portion)
  #   list = path.split(/[\\\/]/)
  #   list.select! { |unit| !unit.empty? } # This line is very important !!
  #   find_file_by_unit(folder, list, portion)
  # end

  # Find the file/folder from the root directory.
  # The input argument pathUnits can be of String type or of Array type.
  def find_file(pathUnits, portion=0)
    pathUnits = SplitPath.call(pathUnits) if pathUnits.instance_of? String
    raise 'The path must be nonempty.' unless pathUnits.size > 0
    dir = @root_dir
    pathUnits.each_with_index do |fname, index|
      if dir != nil
        if (index<pathUnits.size) || (portion==0)
          dir = dir.find_file(fname) # folder
        else
          dir = dir.find_file(fname, portion) # file
        end
      end
    end
    return dir
  end

end
