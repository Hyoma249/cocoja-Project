class Post < ApplicationRecord
  # 投稿は 1つの都道府県 にひもづく
  belongs_to :prefecture
  # 投稿は 1人のユーザー にひもづく
  belongs_to :user

  has_many :post_hashtags
  has_many :hashtags, through: :post_hashtags

  # 投稿内容に # がついている場合、それをハッシュタグとして登録する
  after_create do
    hashtags = self.content.scan(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー]+/)
    self.hashtags.clear
    hashtags.uniq.each do |hashtag|
      tag = Hashtag.find_or_create_by(name: hashtag.downcase.delete('#＃'))
      self.hashtags << tag
    end
  end
end
