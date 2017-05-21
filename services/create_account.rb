class CreateAccount
  def self.call(registration)
    account = Account.new(name: registration[:name], email: registration[:email], passwd: registration[:passwd])
    account.passwd = registration[:passwd]
    account.save
  end
end
