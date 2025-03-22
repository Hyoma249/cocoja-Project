class Hashtag < ApplicationRecord
  has_many :post_hashtags
  has_many :posts, through: :post_hashtags

  validates :name, length: { maximum:99 }
end
