# frozen_string_literal: true

# ユーザー間のフォロー関係を管理するモデル
class Relationship < ApplicationRecord
  # アソシエーション
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  # バリデーション
  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :not_follow_yourself

  private

  def not_follow_yourself
    errors.add(:followed_id, '自分自身をフォローすることはできません') if follower_id == followed_id
  end
end
