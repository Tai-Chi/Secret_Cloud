require 'sequel'

class Tree
  public
  attr_reader :root_dir #<Fileinfo>
  #attr_reader :fList #<Array of Fileinfo>

  # Specify someone's file system
  # How to recover the whole tree from the sql table?
  def initialize(uid, uname)
    raise 'uname cannot be nil' unless uname != nil
    fList = []
    ftable = User[uid].fileinfos
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
      @root_dir = Fileinfo.create(folder: true, name: 'ROOT', user_id: uid, portion: 0)
      @root_dir.parent_id = @root_dir.id
      @root_dir.save
      fList[@root_dir.id] = @root_dir
    end
  end

  def find_file_by_path(folder, path, portion)
    list = path.split(/[\\\/]/)
    list.select! { |unit| !unit.empty? } # This line is very important !!
    find_file_by_unit(folder, list, portion)
  end

  def find_file_by_unit(folder, pathUnits, portion)
    raise 'The path must be nonempty.' unless pathUnits.size > 0
    dir = @root_dir
    pathUnits.each_with_index do |fname, index|
      dir = dir.find_file((index!=pathUnits.size-1)||folder, fname, portion) if dir != nil
    end
    return dir
  end

end
