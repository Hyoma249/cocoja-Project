# ユーザーに残りの日次ポイント数カラムを追加するマイグレーション
class AddRemainingDailyPointsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :remaining_daily_points, :integer
  end
end
