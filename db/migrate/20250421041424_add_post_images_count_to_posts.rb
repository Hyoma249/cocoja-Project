# 投稿画像のカウンターキャッシュカラムを追加するマイグレーション
class AddPostImagesCountToPosts < ActiveRecord::Migration[7.1]
  def up
    add_column :posts, :post_images_count, :integer, default: 0

    # 既存レコードの更新
    update_existing_post_image_counts
  end

  def down
    remove_column :posts, :post_images_count
  end

  private

  # 既存の投稿画像カウントを更新
  def update_existing_post_image_counts
    # 全ての投稿を取得し、それぞれに対して画像数をカウント
    Post.find_each do |post|
      # SQLを直接使用してカウンターを更新（モデル検証をスキップする警告を回避）
      execute <<-SQL.squish
        UPDATE posts
        SET post_images_count = (
          SELECT COUNT(*)
          FROM post_images
          WHERE post_images.post_id = #{post.id}
        )
        WHERE id = #{post.id}
      SQL
    end
  end
end
