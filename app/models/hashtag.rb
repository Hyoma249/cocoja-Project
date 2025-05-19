class Hashtag < ApplicationRecord
  has_many :post_hashtags, dependent: :destroy
  has_many :posts, through: :post_hashtags

  validates :name, presence: true,
                   length: { maximum: 99 },
                   uniqueness: { case_sensitive: false }

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end
end
