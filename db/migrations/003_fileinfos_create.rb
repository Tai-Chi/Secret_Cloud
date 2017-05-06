require 'sequel'

Sequel.migration do
  change do
    create_table(:fileinfos) do
      primary_key :id
      String :name_secure, null: false, text: true
      # TrueClass :folder, null:false
      foreign_key :parent_id, :fileinfos 
      foreign_key :account_id, :accounts
      Integer :portion
      foreign_key :gaccount_id, :gaccounts
      String :gfid_secure, text: true
      Integer :size
    end
  end
end
