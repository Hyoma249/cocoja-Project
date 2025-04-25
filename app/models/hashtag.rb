class Hashtag < ApplicationRecord
  has_many :post_hashtags
  has_many :posts, through: :post_hashtags

  validates :name, presence: true, 
                  length: { maximum: 99 }, 
                  uniqueness: { case_sensitive: false }

  # 保存前に名前を小文字に変換
  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end
