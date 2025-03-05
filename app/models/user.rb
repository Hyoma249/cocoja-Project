class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # usersテーブルとのアソシエーション（1:1）
  has_one :profile, dependent: :destroy # ユーザーが削除されたらプロフィールも削除される
end
