class RankingsController < ApplicationController
  def index
    @current_rankings = WeeklyRanking.current_week.includes(:prefecture).order(rank: :asc)

    # 現在の週のランキングがまだない場合は、リアルタイムで計算
    if @current_rankings.empty?
      @current_rankings = calculate_current_rankings
    end

    @previous_rankings = WeeklyRanking.previous_week.includes(:prefecture).order(rank: :asc)
  end

  private

  def calculate_current_rankings
    start_date = Time.zone.now.beginning_of_week
    end_date = Time.zone.now

    # 都道府県ごとの獲得ポイントを計算
    prefecture_points = {}
    Prefecture.all.each do |prefecture|
      points = prefecture.weekly_points(start_date, end_date)
      prefecture_points[prefecture.id] = { prefecture: prefecture, points: points }
    end

    # ポイント降順でソート（ポイントが高い順に並び替え）
    sorted_prefectures = prefecture_points.values.sort_by { |p| -p[:points] }

    # ランキング形式に変換
    sorted_prefectures.map.with_index do |data, index|
      OpenStruct.new(
        prefecture: data[:prefecture],
        rank: index + 1,
        points: data[:points]
      )
    end
  end
end
