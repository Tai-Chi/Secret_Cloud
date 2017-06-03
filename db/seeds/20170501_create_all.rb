Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, fileinfos, gaccounts'
    create_accounts
    create_gaccounts
    #create_configurations
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ALL_ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts.yml")
ALL_GACCOUNTS_INFO = YAML.load_file("#{DIR}/gaccounts.yml")

def create_accounts
  ALL_ACCOUNTS_INFO.each { |account_info| CreateAccount.call(account_info) }
end

def create_gaccounts
  ALL_GACCOUNTS_INFO.each { |gaccount_info| CreateGaccount.call(gaccount_info) }
end