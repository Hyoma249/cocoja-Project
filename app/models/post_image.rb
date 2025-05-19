class PostImage < ApplicationRecord
  belongs_to :post, counter_cache: true
  mount_uploader :image, PostImageUploader
end
