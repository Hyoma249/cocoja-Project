# app/jobs/update_current_ranking_job.rb
class UpdateCurrentRankingJob < ApplicationJob
  queue_as :default

  def perform
    # 現在の週の情報を取得
    now = Time.zone.now
    year = now.year
    week_number = now.strftime('%U').to_i
    start_date = now.beginning_of_week
    end_date = now

    # 既存の現在週のランキングを削除
    WeeklyRanking.where(year: year, week: week_number).destroy_all

    # 一括クエリで都道府県ごとのポイントを取得
    prefecture_points = Prefecture.weekly_points_for_all(start_date, end_date)

    # 都道府県情報をプリロード
    prefectures = Prefecture.all.index_by(&:id)

    # ゼロポイントの都道府県も含める
    prefectures.each do |id, prefecture|
      prefecture_points[id] ||= 0
    end

    # ソートしてランキング作成
    ranked_prefectures = prefecture_points.sort_by { |_, points| -points }

    # ランキングレコードを保存
    ActiveRecord::Base.transaction do
      ranked_prefectures.each_with_index do |(prefecture_id, points), index|
        WeeklyRanking.create!(
          prefecture_id: prefecture_id,
          year: year,
          week: week_number,
          rank: index + 1,
          points: points
        )
      end
    end

    # キャッシュを更新
    Rails.cache.delete("current_rankings")
  end
end