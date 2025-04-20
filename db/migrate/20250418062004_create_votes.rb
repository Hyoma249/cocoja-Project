class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.integer :points, null: false

      t.timestamps
    end

    # 同じユーザーが同じ投稿に対して一度だけ投票できるようにインデックスを追加
    add_index :votes, [:user_id, :post_id], unique: true, 
              name: 'index_votes_on_user_id_and_post_id'

    # 日付チェックはアプリケーションのバリデーションで行う
  end
end