class GetAccountID
  def self.call(uname)
    Account.where(:name => uname).first.id
  end
end
