class Post < ApplicationRecord
  # 投稿は 1つの都道府県 にひもづく
  belongs_to :prefecture
end
