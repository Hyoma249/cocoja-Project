class Post < ApplicationRecord
  # 投稿は 1つの都道府県 にひもづく
  belongs_to :prefecture

  # 投稿は 1人のユーザー にひもづく
  belongs_to :user

  # ハッシュタグとの関連付け
  has_many :post_hashtags
  has_many :hashtags, through: :post_hashtags

  has_many :votes, dependent: :destroy
  # この投稿が、全部で何ポイント投票されているか？
  def total_points
    votes.sum(:points)
  end

  # 画像アップロード用
  has_many :post_images, dependent: :destroy
  # 1つのフォームで投稿＋画像を一緒に追加・編集・削除できるようにする
  accepts_nested_attributes_for :post_images, allow_destroy: true

  # 画像枚数の上限を10枚に制限
  validates_associated :post_images
  validate :post_images_count_within_limit

  # 投稿内容に # がついている場合、それをハッシュタグとして登録する
  after_create :create_hashtags

  # JSON応答用に日付をフォーマットするメソッド
  def created_at_formatted
    created_at.strftime("%Y年%m月%d日")
  end

  private

  def post_images_count_within_limit
    max_images = 10
    if post_images.size > max_images
      errors.add(:post_images, "は#{max_images}枚まで投稿できます")
    end
  end

  def create_hashtags
    hashtags = content.scan(/#([^\s]+)/).flatten.map(&:downcase).uniq
    hashtags.each do |tag|
      hashtag = Hashtag.find_or_create_by(name: tag)
      post_hashtags.create(hashtag: hashtag)
    end
  end
end
