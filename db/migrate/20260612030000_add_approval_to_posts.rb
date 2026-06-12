class AddApprovalToPosts < ActiveRecord::Migration[7.2]
  def up
    add_column :posts, :approved_at, :datetime
    add_column :posts, :approved_by_id, :bigint
    add_index :posts, :approved_at
    add_index :posts, :approved_by_id

    # Posts that already exist were public before this change, so keep them
    # visible instead of retroactively dropping them into the moderation queue.
    execute "UPDATE posts SET approved_at = created_at WHERE approved_at IS NULL"
  end

  def down
    remove_index :posts, :approved_by_id
    remove_index :posts, :approved_at
    remove_column :posts, :approved_by_id
    remove_column :posts, :approved_at
  end
end
