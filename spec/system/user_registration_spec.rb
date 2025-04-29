require 'rails_helper'

RSpec.describe 'ユーザー登録' do
  describe '新規登録' do
    before { visit new_user_registration_path }

    context '正常な値の場合' do
      it '登録に成功すること' do
        # メールアドレスとパスワードの入力
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワードの確認', with: 'password123'

        # submitボタンを特定してクリック
        within 'form' do
          find('input[type="submit"]').click
        end

        # プロフィール設定ページでの入力
        expect(current_path).to eq profile_setup_path
        fill_in 'ユーザー名', with: 'testuser'
        fill_in 'ID', with: 'testid123'

        within 'form' do
          find('input[type="submit"]').click
        end

        # リダイレクトとメッセージの確認
        expect(page).to have_content 'プロフィールが登録されました'
        expect(current_path).to eq top_page_login_path
      end
    end

    context '無効な値の場合' do
      it '登録に失敗すること' do
        fill_in 'メールアドレス', with: 'invalid-email'
        fill_in 'パスワード', with: 'short'
        fill_in 'パスワードの確認', with: 'different'
        find('input[type="submit"][value="登録する"]').click

        # 実際のエラーメッセージに合わせて修正
        expect(page).to have_content 'Eメールは不正な値です'
        expect(page).to have_content 'パスワードは6文字以上で入力してください'
        expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
        expect(current_path).to eq user_registration_path
      end
    end
  end
end
