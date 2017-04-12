require 'json'
require 'sequel'

class Gaccount < Sequel::Model
  one_to_many :tfiles

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
