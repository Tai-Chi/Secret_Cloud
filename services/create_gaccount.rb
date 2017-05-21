class CreateGaccount
  def self.call(registration)
    gaccount = Gaccount.new(name: registration[:name], passwd: registration[:passwd], size: registration[:size])
    gaccount.name = registration[:name]
    gaccount.passwd = registration[:passwd]
    gaccount.save
  end
end
