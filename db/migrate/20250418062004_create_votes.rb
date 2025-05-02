# 投票機能のテーブルを作成するマイグレーション
class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    add_index :votes, %i[user_id post_id], unique: true
  end
end
