# 都道府県を管理するモデル
class Prefecture < ApplicationRecord
  # 都道府県は たくさんの投稿 を持てる
  has_many :posts, dependent: :nullify
  has_many :weekly_rankings, dependent: :destroy

  # バリデーション
  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false }

  # この都道府県にあるすべての投稿に対して、指定された期間内の投票ポイントの合計
  def weekly_points(start_date, end_date)
    posts.joins(:votes)
         .where(votes: { created_at: start_date..end_date })
         .sum('votes.points')
  end

  # 現在の週の投票ポイントの合計
  def current_week_points
    start_date = Time.zone.now.beginning_of_week
    end_date = Time.zone.now
    weekly_points(start_date, end_date)
  end
end
