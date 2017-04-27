require 'json'
require 'sequel'

class Account < Sequel::Model
  one_to_many :fileinfos

  def to_json(options = {})
    JSON({
           type: 'account',
           id: id,
           attributes: {
             name: name,
            #  passwd: passwd
           }
         },
         options)
  end

end
