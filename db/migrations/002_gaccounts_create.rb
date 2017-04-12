require 'sequel'

Sequel.migration do
  change do
    create_table(:gaccounts) do
      primary_key :id
      String :name, null: false
      String :passwd, null: false
      Integer :size
    end
  end
end
