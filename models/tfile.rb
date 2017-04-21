require 'json'
require 'sequel'

class Tfile < Sequel::Model
  public
  attr_reader :list #<Array of Tfile>

  many_to_one :user
  many_to_one :gaccount
  many_to_one :parent, :class=>self
  one_to_many :children, :class=>self, :key=>:parent_id

  def add_file(file)
    raise 'we can only add file into a folder.' unless folder
    raise 'file of course must be of type Tfile.' unless file.instance_of? Tfile
    @list ||= []
    @list.push(file)
  end

  def find_file(dir, name, portion)
    raise 'We can only find a file in a folder.' unless folder
    @list ||= children
    @list.each do |file|
      return file if file.folder==dir && file.name==name && (dir||(file.portion==portion))
    end
    return nil
  end

  def recur_delete
    @list ||= children
    @list.each do |file|
      if file.folder
        file.recur_delete
      else
        file.delete
      end
    end
    @list = []
    self.delete
  end

  def to_json(options = {})
    JSON({
           type: 'tfile',
           id: id,
           attributes: {
             name: name,
             folder: folder,
             parent: parent_id,
             user: user_id,
             portion: portion,
             gaccount: gaccount_id,
             gfid: gfid
           }
         },
         options)
  end
end
