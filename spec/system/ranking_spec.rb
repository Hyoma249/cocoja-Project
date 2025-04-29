require 'rails_helper'

RSpec.describe 'ランキング機能' do
  let(:user) { create(:user) }
  let(:prefecture) { create(:prefecture, name: '東京都') }
  let!(:other_prefecture) { create(:prefecture, name: '大阪府') }

  describe 'ランキング表示' do
    before do
      # 各都道府県の投稿を作成
      @tokyo_post = create(:post, user: user, prefecture: prefecture)
      @osaka_post = create(:post, user: user, prefecture: other_prefecture)

      # 異なる日付で投票を作成（上限バリデーションを回避）
      3.times do |i|
        voter = create(:user)
        travel_to (i + 1).day.ago do
          create(:vote, user: voter, post: @tokyo_post, points: 2)
          create(:vote, user: voter, post: @osaka_post, points: 1)
        end
      end

      login_as(user)
      visit rankings_path
    end

    after do
      travel_back
    end

    it 'ランキングが正しく表示されること' do
      expect(page).to have_content '都道府県魅力度ランキング'
      expect(page).to have_content '今週のランキング'

      # 東京都が1位、大阪府が2位であることを確認
      within('.divide-y') do
        rankings = all('h3').map(&:text)
        expect(rankings[0]).to eq '東京都'
        expect(rankings[1]).to eq '大阪府'
      end
    end

    context '投票がない場合' do
      before do
        Vote.destroy_all
        visit rankings_path
      end

      it 'ポイントが0と表示されること' do
        expect(page).to have_content '0ポイント'
      end
    end
  end
end
