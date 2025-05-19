class Post < ApplicationRecord
  belongs_to :prefecture
  belongs_to :user

  has_many :post_hashtags, dependent: :destroy
  has_many :hashtags, through: :post_hashtags
  has_many :votes, dependent: :destroy

  def total_points
    votes.sum(:points)
  end

  has_many :post_images, -> { order(created_at: :asc) }, dependent: :destroy, autosave: false
  accepts_nested_attributes_for :post_images, allow_destroy: true

  validates_associated :post_images
  validate :post_images_count_within_limit

  after_create :create_hashtags

  def created_at_formatted
    I18n.l(created_at, format: :long) if created_at
  end

  def increment_images_count!
    increment!(:post_images_count)
  end

  private

  def post_images_count_within_limit
    max_images = 5
    return unless post_images.size > max_images

    errors.add(:post_images, "は#{max_images}枚まで投稿できます")
  end

  def create_hashtags
    hashtags = content.scan(/[#＃]([^\s#＃]+)/).flatten.map(&:downcase).uniq
    hashtags.each do |tag|
      hashtag = Hashtag.find_or_create_by(name: tag)
      post_hashtags.create(hashtag: hashtag)
    end
  end
end
