# ランキング（Ranking）に関する操作を担当するコントローラー
# 週間ランキングの表示や計算機能を提供します
class RankingsController < ApplicationController
  def index
    @current_rankings = WeeklyRanking.current_week.includes(:prefecture).order(rank: :asc)

    # 現在の週のランキングがまだない場合は、リアルタイムで計算
    @current_rankings = calculate_current_rankings if @current_rankings.empty?

    @previous_rankings = WeeklyRanking.previous_week.includes(:prefecture).order(rank: :asc)
  end

  private

  def calculate_current_rankings
    start_date = Time.zone.now.beginning_of_week
    end_date = Time.zone.now

    # 都道府県ごとの獲得ポイントを計算
    prefecture_points = calculate_prefecture_points(start_date, end_date)

    # ポイント降順でソート（ポイントが高い順に並び替え）
    sorted_prefectures = prefecture_points.values.sort_by { |p| -p[:points] }

    # ランキング形式に変換
    convert_to_ranking_format(sorted_prefectures)
  end

  def calculate_prefecture_points(start_date, end_date)
    prefecture_points = {}
    Prefecture.find_each do |prefecture|
      points = prefecture.weekly_points(start_date, end_date)
      prefecture_points[prefecture.id] = { prefecture: prefecture, points: points }
    end
    prefecture_points
  end

  def convert_to_ranking_format(sorted_prefectures)
    sorted_prefectures.map.with_index do |data, index|
      build_ranking_item(data[:prefecture], index + 1, data[:points])
    end
  end

  def build_ranking_item(prefecture, rank, points)
    Struct.new(:prefecture, :rank, :points).new(prefecture, rank, points)
  end
end
