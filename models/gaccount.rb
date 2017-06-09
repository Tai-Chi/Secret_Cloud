require 'json'
require 'sequel'

class Gaccount < Sequel::Model
  many_to_one :account
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
             size: size,
             account: account_id
           }
         },
         options)
  end
end
