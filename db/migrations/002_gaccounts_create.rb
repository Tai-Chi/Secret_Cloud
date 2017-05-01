require 'sequel'

Sequel.migration do
  change do
    create_table(:gaccounts) do
      primary_key :id
      String :name_secure, null: false, text: true
      String :passwd_hash, null: false, text: true
      String :salt, null: false
      Integer :size
    end
  end
end
