class AddConfirmableToUsers < ActiveRecord::Migration[7.1]
  def change
    # まだカラムが存在していない場合のみ追加
    unless column_exists?(:users, :confirmation_token)
      add_column :users, :confirmation_token, :string
      add_column :users, :confirmed_at, :datetime
      add_column :users, :confirmation_sent_at, :datetime
      add_column :users, :unconfirmed_email, :string
      add_index :users, :confirmation_token, unique: true
    end

    # 既存ユーザーを確認済みにする
    reversible do |dir|
      dir.up { User.update_all(confirmed_at: DateTime.now) if User.count > 0 }
    end
  end
end