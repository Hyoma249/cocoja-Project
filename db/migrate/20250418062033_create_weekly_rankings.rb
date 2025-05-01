class CreateWeeklyRankings < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_rankings do |t|
      t.references :prefecture, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :week, null: false
      t.integer :rank, null: false
      t.integer :points, null: false, default: 0

      t.timestamps
    end

    # 同じ年・週に対して都道府県が重複しないようにするためのユニーク制約
    add_index :weekly_rankings, [ :prefecture_id, :year, :week ], unique: true,
               name: "index_weekly_rankings_on_prefecture_year_week"
  end
end
