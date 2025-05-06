class AddOmniauthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid_from_provider, :string
    add_index :users, [:provider, :uid_from_provider], unique: true
  end
end
