require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id
      String :name, null: false
      String :passwd, null: false
    end
  end
end
