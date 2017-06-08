require 'econfig'
require 'sinatra'

# API of Backup File System
class FileSystemSyncAPI < Sinatra::Base
  extend Econfig::Shortcut

  configure do
    enable :logging

    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureDB.setup(settings.config.DB_KEY)
    AuthToken.setup(settings.config.DB_KEY)
  end

  def authenticated_account(env)
    begin
      scheme, auth_token = env['HTTP_AUTHORIZATION'].split(' ')
      return nil unless scheme.match?(/^Bearer$/i)

      account_payload = AuthToken.payload(auth_token)
      Account[account_payload['id']]
    rescue
      nil
    end
  end

  def authorized_account?(env, id)
    account = authenticated_account(env)
    account.id.to_s == id.to_s
  rescue
    false
  end

  def _403_if_not_logged_in(account)
    if account.nil?
      logger.info "User should log in first."
      halt 403
    end
  end

  get '/?' do
    'File System Synchronization web API'
  end

end
