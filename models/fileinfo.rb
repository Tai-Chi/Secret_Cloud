require 'json'
require 'sequel'

class Fileinfo < Sequel::Model
  
  attr_reader :list #<Array of Fileinfo>

  many_to_one :account
  many_to_one :gaccount
  many_to_one :parent, :class=>self
  one_to_many :children, :class=>self, :key=>:parent_id

  # override the original method
  # it is similar to initialize of usual classes
  def before_create
    super
    @list = []
  end

  def name=(desc_plain)
    self.name_secure = SecureDB.encrypt(desc_plain)
  end

  def name
    SecureDB.decrypt(name_secure)
  end

  def gfid=(desc_plain)
    self.gfid_secure = SecureDB.encrypt(desc_plain)
  end

  def gfid
    SecureDB.decrypt(gfid_secure)
  end

  def add_file(file)
    raise 'we can only add file into a folder.' unless self.portion==0
    raise 'file of course must be of type Fileinfo.' unless file.instance_of? Fileinfo
    #@list ||= children
    @list.push(file)
  end

  # If we want to find a directory, then the portion number can be automatically zero.
  def find_file(name, portion=0)
    raise 'We can only find a file in a folder.' unless self.portion==0
    portion = Integer(portion) if portion.instance_of? String
    #@list ||= children
    @list.each do |file|
      return file if file.name==name && file.portion==portion
    end
    return nil
  end

  def recur_delete
    # @list ||= children
    @list.each do |file|
      if file.portion==0
        file.recur_delete
      else
        file.delete
      end
    end
    @list = []
    self.delete
  end

  def delete_file(fname)
    #@list ||= children
    rm_list = []
    @list.each do |file|
      if !(file.portion==0) && file.name == fname
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
            #  folder: folder,
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
