# Find account and check password
class AuthenticateAccount
  def self.call(credentials)
    account = Account.first(name: credentials[:username])
    return nil unless account&.passwd?(credentials[:passwd])
    { account: account, auth_token: AuthToken.create(account) }
  end
end
