require 'rails_helper'

RSpec.describe RankingsController, type: :controller do
  describe 'GET #index' do
    let!(:prefecture1) { create(:prefecture, name: '東京都') }
    let!(:prefecture2) { create(:prefecture, name: '大阪府') }
    let!(:user) { create(:user) }
    let!(:post1) { create(:post, prefecture: prefecture1) }
    let!(:post2) { create(:post, prefecture: prefecture2) }

    context '現在の週のランキングが存在する場合' do
      let!(:current_ranking1) do
        create(:weekly_ranking,
          prefecture: prefecture1,
          rank: 1,
          points: 100,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i
        )
      end

      let!(:current_ranking2) do
        create(:weekly_ranking,
          prefecture: prefecture2,
          rank: 2,
          points: 50,
          year: Time.current.year,
          week: Time.current.strftime('%U').to_i
        )
      end

      it '現在の週のランキングを取得すること' do
        get :index
        expect(assigns(:current_rankings)).to match_array([current_ranking1, current_ranking2])
      end

      it 'ランキング順に並んでいること' do
        get :index
        expect(assigns(:current_rankings).to_a).to eq([current_ranking1, current_ranking2])
      end
    end

    context '現在の週のランキングが存在しない場合' do
      before do
        create(:vote, post: post1, points: 5, created_at: Time.zone.now)
        create(:vote, post: post2, points: 3, created_at: Time.zone.now)
      end

      it 'リアルタイムでランキングを計算すること' do
        get :index
        rankings = assigns(:current_rankings)

        expect(rankings.length).to eq(2)
        expect(rankings.first.prefecture).to eq(prefecture1)
        expect(rankings.first.rank).to eq(1)
        expect(rankings.second.prefecture).to eq(prefecture2)
        expect(rankings.second.rank).to eq(2)
      end
    end

    context '前週のランキングが存在する場合' do
      let!(:previous_ranking) do
        create(:weekly_ranking,
          prefecture: prefecture1,
          rank: 1,
          points: 100,
          year: 1.week.ago.year,
          week: 1.week.ago.strftime('%U').to_i
        )
      end

      it '前週のランキングを取得すること' do
        get :index
        expect(assigns(:previous_rankings)).to include(previous_ranking)
      end
    end
  end
end
