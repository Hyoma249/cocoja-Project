class Profile < ApplicationRecord
  belongs_to :user # usersテーブルとのアソシエーション（1:1）

  validates :username, length: { minimum: 2, maximum: 20 }
  validates :uid, format: { with: /\A[a-zA-Z0-9]+\z/ }, length: { minimum: 6, maximum: 15 }, uniqueness: true
end
