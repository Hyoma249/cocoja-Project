class UpdateVotesUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    # 既存のインデックスを削除
    remove_index :votes, [:user_id, :post_id], if_exists: true

    # 代わりに created_on カラムを追加
    add_column :votes, :voted_on, :date, null: false, default: -> { 'CURRENT_DATE' }

    # 新しい複合インデックスを作成
    add_index :votes, [:user_id, :post_id, :voted_on], unique: true, name: "index_votes_on_user_id_post_id_and_date"
  end
end
