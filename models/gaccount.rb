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

  def passwd=(new_password)
    self.salt = SecureDB.new_salt
    self.passwd_hash = SecureDB.hashed_password(self.salt, new_password)
  end

  def passwd?(try_password)
    try_hashed = SecureDB.hashed_password(self.salt, try_password)
    try_hashed == self.passwd_hash
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
