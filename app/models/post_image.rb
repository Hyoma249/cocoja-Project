class PostImage < ApplicationRecord
  belongs_to :post
  # image カラムに画像ファイルをアップロードできるようにする
  mount_uploader :image, PostImageUploader
end
