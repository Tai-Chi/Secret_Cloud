require 'sequel'

class Tree
  private:
  attr_reader :root_dir #<File>
=begin
# A recursive function to add files
  def traverse(ftable, dir)
    subtable = ftable.where('pid = #{dir.id}').all
    subtable.each do |rec|
      dir.add_file(File.new(rec[:attr]=='file',rec[:name],rec[:id]))
      if rec[:attr]=='folder'
        traverse(ftable, dir.find_file(rec[:attr], rec[:name]))
      end
    end
  end
=end
  public:
  # Specify someone's file system
  # How to recover the whole tree from the sql table?
  def initialize(uname)
    raise 'uname cannot be NIL' unless uname != NIL
    # raise 'utable cannot be NIL' unless utable != NIL
    # raise 'ftable cannot be NIL' unless ftable != NIL
    uid = User.where('name = #{uname}').select('id')
    ftable = File.where('uid = #{uid}')
    ftable.each do |file|
      fList.insert(file[:id], File.new(file[:attr]=='file',file[:name],file[:id]))
    end
    ftable.each do |file|
      fList.at(file[:pid]).add_file(fList.at(file[:id]))
    end
    @root_dir = fList.at(1) # File.new(false,'/',1)
    #traverse(ftable, @root_dir)
  end

  # Must give an absolute path.
  def find_file(path)
    list = path.split('/\\')
    raise 'The path must be nonempty.' unless list.size > 0
    dir = @root_dir.clone
    list.each_with_index do |fname, index|
      dir = dir.find_file(index==list.size-1, fname)
    end
    return dir
  end

  # Or give a list of path units.
  def find_file(pathUnits)
    raise 'The path must be nonempty.' unless pathUnits.size > 0
    dir = @root_dir.clone
    pathUnits.each_with_index do |fname, index|
      dir = dir.find_file(index==pathUnits.size-1, fname)
    end
    return dir
  end

end

# This class describes files and folders.
class File
  private:
  attr_reader :type #<boolean> 0:folder, 1:file
  attr_reader :name #<String>
  attr_reader :id   #<Integer>
  attr_reader :list #<Array of File>

  public:
  def initialize(type, name, id)
    raise 'type must be a boolean value.' unless type.boolean?
    raise 'name must be a string.' unless name.must_be_instance_of? String
    raise 'id must be an integer.' unless id.must_be_instance_of? Integer
    @type = type
    @name = name
    @id   = id
  end

  def add_file(file)
    raise 'we can only add file into a folder.' unless type==false
    raise 'file of course must be of type FILE.' unless file.must_be_instance_of? FILE
    list.push(file)
  end
=begin
  def give_id(id)
    raise 'id must be of type Integer.' unless id.must_be_instance_of? Integer
    @id = id
  end

  def to_json(options = {})
    JSON( { type: @type,
            id: @id,
            name: @name
          },
          options)
  end
=end
  # Giving short name is enough.
  def find_file(type, name)
    raise 'We can only find a file in a folder.' unless type==false
    @list.each do |file|
      if file.type==type && file.name==name
        return file
    end
    return NIL
  end
end
