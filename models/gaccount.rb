require 'json'
require 'sequel'

class Gaccount < Sequel::Model
  one_to_many :fileinfos

  def name=(desc_plain)
    self.name_secure = SecureDB.encrypt(desc_plain)
  end

  def name
    SecureDB.decrypt(name_secure)
  end

  def to_json(options = {})
    JSON({
           type: 'gaccount',
           id: id,
           attributes: {
             name: name,
             passwd: passwd,
             size: size
           }
         },
         options)
  end
end
