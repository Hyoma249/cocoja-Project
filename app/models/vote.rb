# app/models/vote.rb
class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # 1以上5以下の整数だけを許しますというバリデーション
  validates :points, numericality: {
    only_integer: true, # 整数（小数じゃない）じゃないとダメ
    greater_than: 0, # 0より大きい
    less_than_or_equal_to: 5 # 5以下
  }
  validate :daily_point_limit
  validate :cannot_vote_own_post
  validate :has_not_already_voted_today

  # 1日に投票したレコードを取得するためのスコープ
  scope :today, -> { where('created_at >= ?', Time.zone.today.beginning_of_day) }

  private

  def daily_point_limit # 1日に合計 5ポイントまでしか投票できない
    return unless user

    total_points_today = user.votes.today.sum(:points)
    remaining_points = 5 - total_points_today

    if points > remaining_points # 1日の投票ポイント上限を超えている場合 エラー表示をさせる。
      errors.add(:points, "1日の投票ポイント上限（5ポイント）を超えています。残り#{remaining_points}ポイントです。")
    end
  end

  def cannot_vote_own_post # 自分の投稿にはポイントを付けられない
    return unless user && post

    if user_id == post.user_id # 自分の投稿に投票しようとした場合
      errors.add(:post, "自分の投稿にはポイントを付けられません")
    end
  end

  def has_not_already_voted_today # 同じ日に同じ投稿に対して既に投票しているかチェック
    return unless user && post

    # 同じ日に同じ投稿に対して既に投票しているかチェック
    if user.votes.today.where(post_id: post.id).exists? # 既に投票している場合
      errors.add(:post, "同じ投稿に1日に複数回ポイントを付けることはできません")
    end
  end
end