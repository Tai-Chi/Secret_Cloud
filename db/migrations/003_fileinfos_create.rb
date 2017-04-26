require 'sequel'

Sequel.migration do
  change do
    create_table(:fileinfos) do
      primary_key :id
      String :name, null: false
      TrueClass :folder, null:false
      foreign_key :parent_id, :fileinfos 
      foreign_key :user_id, :users
      Integer :portion
      foreign_key :gaccount_id, :gaccounts
      String :gfid
    end
  end
end
