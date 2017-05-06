# Find account and check password
class AuthenticateAccount
  def self.call(credentials)
    account = Account.first(name: credentials['username'])
    (account == nil) ? false : account.passwd?(credentials['passwd'])
  end
end
