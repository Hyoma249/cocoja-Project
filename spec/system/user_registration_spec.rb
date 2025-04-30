# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザー登録', type: :system do
  before do
    driven_by(:rack_test)
    visit new_user_registration_path
  end

  describe '新規登録' do
    context 'when 正常な値の場合' do
      before do
        within 'form' do
          fill_in 'メールアドレス', with: 'test@example.com'
          fill_in 'パスワード', with: 'password123'
          fill_in 'パスワードの確認', with: 'password123'
          click_button '登録する'
        end
      end

      it 'メールアドレス登録に成功すること' do
        expect(page).to have_current_path(profile_setup_path)
      end

      context 'when プロフィール設定時' do
        before do
          within 'form' do
            fill_in 'ユーザー名', with: 'testuser'
            fill_in 'ユーザーID（半角英数字）', with: 'testid123'
            click_button 'はじめる'
          end
        end

        it 'プロフィール設定が完了すること' do
          expect(page).to have_current_path(top_page_login_path)
          expect(page).to have_content 'プロフィールが登録されました'
        end
      end
    end

    context 'when 無効な値の場合' do
      it '登録に失敗すること' do
        within 'form' do
          fill_in 'メールアドレス', with: 'invalid-email'
          fill_in 'パスワード', with: 'short'
          fill_in 'パスワードの確認', with: 'different'
          click_button '登録する'
        end

        expect(page).to have_current_path(user_registration_path)
        expect(page).to have_content 'Eメールは不正な値です'
        expect(page).to have_content 'パスワードは6文字以上で入力してください'
      end
    end
  end
end
