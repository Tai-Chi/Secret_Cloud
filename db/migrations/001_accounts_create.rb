require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id
      String :name, null: false
      String :email, null: false
      String :passwd_hash, null: false, text: true
      String :salt, null: false
    end
  end
end
