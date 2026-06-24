class AddLinkAndEmbedToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :post_type, :string, null: false, default: "media"
    add_column :posts, :link_url, :string
    add_column :posts, :og_title, :string
    add_column :posts, :og_description, :text
    add_column :posts, :og_image_url, :string
    add_column :posts, :og_site_name, :string
  end
end
