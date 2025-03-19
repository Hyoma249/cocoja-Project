class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # ユーザーは たくさんの投稿 を持てる
  has_many :posts

  validates :username, length: { minimum: 2, maximum: 20 }, uniqueness: true, presence: true, allow_nil: true
  validates :uid, format: { with: /\A[a-zA-Z0-9]+\z/ }, length: { minimum: 6, maximum: 15 }, uniqueness: true, presence: true, allow_nil: true
end
