class Post < ApplicationRecord
  # 投稿は 1つの都道府県 にひもづく
  belongs_to :prefecture
  # 投稿は 1人のユーザー にひもづく
  belongs_to :user
end
