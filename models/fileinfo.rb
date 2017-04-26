require 'json'
require 'sequel'

class Fileinfo < Sequel::Model
  public
  attr_reader :list #<Array of Fileinfo>

  many_to_one :account
  many_to_one :gaccount
  many_to_one :parent, :class=>self
  one_to_many :children, :class=>self, :key=>:parent_id

  def add_file(file)
    raise 'we can only add file into a folder.' unless folder
    raise 'file of course must be of type Fileinfo.' unless file.instance_of? Fileinfo
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

  def delete_file(fname)
    @list ||= children
    rm_list = []
    @list.each do |file|
      if !file.folder && file.name == fname
        file.delete
        rm_list.push(file)
      end
    end
    rm_list.each do |file|
      @list.delete(file)
    end
    rm_list.size != 0
  end

  def to_json(options = {})
    JSON({
           type: 'fileinfo',
           id: id,
           attributes: {
             name: name,
             folder: folder,
             parent: parent_id,
             account: account_id,
             portion: portion,
             gaccount: gaccount_id,
             gfid: gfid
           }
         },
         options)
  end
end
