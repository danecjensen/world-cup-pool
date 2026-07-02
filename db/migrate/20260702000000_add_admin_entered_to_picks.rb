class AddAdminEnteredToPicks < ActiveRecord::Migration[7.2]
  def change
    add_column :picks, :admin_entered, :boolean, default: false, null: false
  end
end
