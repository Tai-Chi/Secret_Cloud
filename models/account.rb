require 'json'
require 'sequel'

class Account < Sequel::Model
  one_to_many :gaccounts
  one_to_many :fileinfos

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
           type: 'account',
           id: id,
           username: name,
           email: email
         }, options)
  end

end
