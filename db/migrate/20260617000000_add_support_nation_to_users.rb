class AddSupportNationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :support_nation, :string
    add_column :users, :support_flag, :string
  end
end
