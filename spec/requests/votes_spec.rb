require 'rails_helper'

RSpec.describe "投票API" do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:prefecture) { create(:prefecture) }
  let!(:post_item) { create(:post, user: other_user, prefecture: prefecture) }

  before do
    sign_in user
  end

  describe 'POST /posts/:post_id/votes' do
    context 'HTMLリクエストの場合' do
      it '投票が成功すること' do
        post "/posts/#{post_item.id}/votes", params: { vote: { points: 3 } }
        expect(response).to redirect_to(post_item)
        follow_redirect!
        expect(response.body).to include('3ポイントを付与しました')
      end
    end

    context 'Turbo Streamsリクエストの場合' do
      it '成功レスポンスを返すこと' do
        post "/posts/#{post_item.id}/votes",
          params: { vote: { points: 3 } },
          headers: { 'Accept': 'text/vnd.turbo-stream.html' }

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include('vote_form')
        expect(response.body).to include('flash')
      end
    end
  end
end
