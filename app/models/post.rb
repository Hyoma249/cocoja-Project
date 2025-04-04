class Post < ApplicationRecord
  # 投稿は 1つの都道府県 にひもづく
  belongs_to :prefecture

  # 投稿は 1人のユーザー にひもづく
  belongs_to :user

  # ハッシュタグとの関連付け
  has_many :post_hashtags
  has_many :hashtags, through: :post_hashtags

  # 画像アップロード用
  has_many :post_images, dependent: :destroy
  # 1つのフォームで投稿＋画像を一緒に追加・編集・削除できるようにする
  accepts_nested_attributes_for :post_images, allow_destroy: true

  # 画像枚数の上限を10枚に制限
  validates_associated :post_images
  validate :post_images_count_within_limit

  # 投稿内容に # がついている場合、それをハッシュタグとして登録する
  after_create do
    hashtags = self.content.scan(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー]+/)
    self.hashtags.clear
    hashtags.uniq.each do |hashtag|
      tag = Hashtag.find_or_create_by(name: hashtag.downcase.delete('#＃'))
      self.hashtags << tag
    end
  end

  private

  def post_images_count_within_limit
    max_images = 10
    if post_images.size > max_images
      errors.add(:post_images, "は#{max_images}枚まで投稿できます")
    end
  end
end
