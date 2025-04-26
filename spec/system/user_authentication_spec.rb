require 'rails_helper'

RSpec.describe 'ユーザー認証', type: :system do
  let(:user) { create(:user) }

  describe 'ログイン' do
    context '有効な情報を入力した場合' do
      it 'ログインに成功すること' do
        visit new_user_session_path
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password
        click_button 'ログイン'

        expect(page).to have_content 'ログインしました'
        expect(current_path).to eq top_page_login_path
      end
    end
  end
end
