class AddPostImagesCountToPosts < ActiveRecord::Migration[7.1]
  def up
    add_column :posts, :post_images_count, :integer, default: 0
    update_existing_post_image_counts
  end

  def down
    remove_column :posts, :post_images_count
  end

  private

  def update_existing_post_image_counts
    Post.find_each do |post|
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
