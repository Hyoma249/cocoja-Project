# 投稿とハッシュタグの中間テーブルを作成するマイグレーション
class CreatePostHashtags < ActiveRecord::Migration[7.1]
  def change
    create_table :post_hashtags do |t|
      t.references :post, index: true, foreign_key: true
      t.references :hashtag, index: true, foreign_key: true

      t.timestamps
    end
  end
end
