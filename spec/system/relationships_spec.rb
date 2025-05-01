# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'フォロー機能', type: :system do
  let(:user) { create(:user, username: 'テストユーザー1', uid: 'testuser1') }
  let(:other_user) { create(:user, username: 'テストユーザー2', uid: 'testuser2') }

  before do
    driven_by(:rack_test)
    sign_in user
  end

  describe 'ユーザーページの表示' do
    context 'when 他のユーザーのページを表示する場合' do
      before { visit user_path(other_user) }

      it 'フォローボタンが表示されること' do
        within('.follow-form') do
          expect(page).to have_button 'フォローする'
        end
      end
    end

    context 'when フォロワーがいる場合' do
      before do
        other_user.follow(user)
        visit user_path(user)
      end

      it 'フォロー/フォロワー数が表示されること' do
        within('.follow-stats') do
          expect(page).to have_content('1')
          expect(page).to have_content('フォロワー')
        end
      end
    end
  end

  describe 'フォロー/フォロワー一覧' do
    before do
      user.follow(other_user)
      visit user_path(user)
    end

    it 'フォロー中のユーザーが表示されること' do
      click_link 'フォロー中'
      expect(page).to have_content(other_user.username)
    end

    it 'フォロワーが表示されること' do
      other_user.follow(user)
      click_link 'フォロワー'
      expect(page).to have_content(other_user.username)
    end
  end
end
