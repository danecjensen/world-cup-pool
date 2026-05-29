class CreateSiteSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :site_settings do |t|
      t.boolean :bracket_visible, null: false, default: false
      t.timestamps
    end
  end
end
