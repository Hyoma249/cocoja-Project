# リレーションシップテーブルにインデックスを追加するマイグレーション
class AddIndexToRelationships < ActiveRecord::Migration[7.1]
  def change
    add_index :relationships, %i[follower_id followed_id], unique: true
  end
end
