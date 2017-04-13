require 'sequel'

class Tree
  public
  attr_reader :root_dir #<Tfile>

  # Specify someone's file system
  # How to recover the whole tree from the sql table?
  def initialize(uid, uname)
    raise 'uname cannot be nil' unless uname != nil
    fList = []
    ftable = User[uid].tfiles
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
      @root_dir = Tfile.create(folder: true, name: 'ROOT', user_id: uid)
      @root_dir.parent_id = @root_dir.id
      @root_dir.save
      fList[@root_dir.id] = @root_dir
    end
  end
=begin
  def find_file_by_path(path)
    list = path.split(/[\\\/]/)
    find_file_by_unit(list)
  end

  def find_file_by_unit(pathUnits)
    raise 'The path must be nonempty.' unless pathUnits.size > 0
    dir = @root_dir.clone
    pathUnits.each_with_index do |fname, index|
      dir = dir.find_file(index==pathUnits.size-1, fname)
    end
    dir
  end
=end
end
