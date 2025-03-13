class Prefecture < ApplicationRecord
  # バリデーション
  validates :name, presence: true, uniqueness: true
end