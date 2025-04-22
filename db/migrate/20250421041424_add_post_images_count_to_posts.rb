class AddPostImagesCountToPosts < ActiveRecord::Migration[7.1]
  def up
    add_column :posts, :post_images_count, :integer, default: 0, null: false

    # 既存のレコードをアップデート
    Post.reset_column_information
    Post.find_each do |post|
      Post.update_counters post.id, post_images_count: post.post_images.count
    end
  end

  def down
    remove_column :posts, :post_images_count
  end
end