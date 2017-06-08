class CreateGaccount
  def self.call(registration)
    gaccount = Gaccount.new(name: registration[:name], size: 15000000000, account_id: registration[:account_id])
    gaccount.name = registration[:name]
    gaccount.save
  end
end
