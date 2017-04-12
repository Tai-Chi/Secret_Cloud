require 'json'
require 'sequel'

class Tfile < Sequel::Model
  many_to_one :user
  many_to_one :gaccount
  many_to_one :parent, :class=>self
  one_to_many :children, :class=>self, :key=>:parent_id

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
