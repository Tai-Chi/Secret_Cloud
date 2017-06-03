require 'json'
require 'sequel'

#Make all model subclasses support the after_initialize hook
Sequel::Model.plugin :after_initialize

class Fileinfo < Sequel::Model

  attr_reader :list #<Array of Fileinfo>

  many_to_one :account
  many_to_one :gaccount
  many_to_one :parent, :class=>self
  one_to_many :children, :class=>self, :key=>:parent_id

  ### invoke right after the original constrctor
  def after_initialize
    @list = []
  end
  ##############################################

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
    rm_list = []
    @list.each do |file|
      if file.portion==0
        rm_list += file.recur_delete
      else
        file.delete
        rm_list += ["#{Gaccount[file.gaccount_id].name} #{file.gfid}"]
      end
    end
    @list = []
    # Please note that a folder has no gaccount ids, so we cannot
    # add the folder into our remove list!!!
    # rm_list += ["#{Gaccount[self.gaccount_id].name} #{self.gfid}"]
    self.delete
    rm_list
  end

  def delete_file(fname)
    #@list ||= children
    rm_list = []
    @list.each do |file|
      if !(file.portion==0) && file.name == fname
        file.delete
        rm_list.push(file)
        # We should always keep the recorded space
        # in our server no more than the real space
        # of the Google Drive, so we update the space
        # through another API, instead of adding
        # here directly.
        # gaccount = Gaccount[file.gaccount_id]
        # gaccount.size += file.size
        # gaccount.save
      end
    end
    rm_list.each do |file|
      @list.delete(file)
    end
    return rm_list.map { |file| "#{Gaccount[file.gaccount_id].name} #{file.gfid}" }
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
