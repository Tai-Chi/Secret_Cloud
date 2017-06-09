require 'sequel'

Sequel.migration do
  change do
    create_table(:gaccounts) do
      primary_key :id
      String :name_secure, null: false, text: true
      Bignum :size # 15000000000 > 2^31 - 1
      foreign_key :account_id, :accounts, on_delete: :cascade
    end
  end
end
