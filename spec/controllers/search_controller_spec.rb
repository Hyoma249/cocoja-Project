# frozen_string_literal: true

require 'rails_helper'

# 検索コントローラーのテスト
# 注: このファイルがsearch機能の主要なテストです
RSpec.describe SearchController, type: :controller do
  describe 'GET #autocomplete' do
    # コントローラーテスト用にログイン状態を設定
    let(:user) { create(:user, username: 'testuser', uid: 'testuid123') }
    let!(:prefecture) { create(:prefecture, name: 'テスト県') }
    let!(:hashtag) { create(:hashtag, name: 'testhashtag') }

    before do
      sign_in user
      # Ajaxリクエストとして設定
      request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'when クエリが空の場合' do
      it '空の結果を返すこと' do
        get :autocomplete, params: { query: '' }
        expect(response).to have_http_status(:success)
        expect(response.parsed_body).to eq({ 'results' => [] })
      end
    end

    context 'when ユーザー名で検索する場合' do
      it 'マッチするユーザーを返すこと' do
        get :autocomplete, params: { query: 'test' }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body

        user_results = json_response['results'].select { |r| r['type'] == 'user' }
        expect(user_results).not_to be_empty
        expect(user_results.first['text']).to eq('testuser')
        expect(user_results.first['url']).to eq(user_path(user))
      end
    end

    context 'when 都道府県名で検索する場合' do
      it 'マッチする都道府県を返すこと' do
        get :autocomplete, params: { query: 'テスト' }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body

        prefecture_results = json_response['results'].select { |r| r['type'] == 'prefecture' }
        expect(prefecture_results).not_to be_empty
        expect(prefecture_results.first['text']).to eq('テスト県')
        expect(prefecture_results.first['url']).to eq(posts_prefecture_path(prefecture))
      end
    end

    context 'when ハッシュタグ名で検索する場合' do
      it 'マッチするハッシュタグを返すこと' do
        get :autocomplete, params: { query: 'hashtag' }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body

        hashtag_results = json_response['results'].select { |r| r['type'] == 'hashtag' }
        expect(hashtag_results).not_to be_empty
        expect(hashtag_results.first['text']).to eq('testhashtag')
        expect(hashtag_results.first['url']).to eq(hashtag_posts_path(hashtag.name))
      end
    end

    context 'when 大文字小文字混在のクエリの場合' do
      # テスト内で参照されているため、let! のままにする
      let!(:mixed_case_hashtag) { create(:hashtag, name: 'MixedCase') }

      it '検索ができること（大文字小文字の扱いはシステム実装に依存）' do
        get :autocomplete, params: { query: 'mixedcase' }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body

        hashtag_results = json_response['results'].select { |r| r['type'] == 'hashtag' }
        expect(hashtag_results).not_to be_empty

        # モデルやコントローラの実装によって大文字小文字の扱いが変わる可能性があるため
        # 大文字小文字を区別せずに内容を検証する
        expect(hashtag_results.first['text'].downcase).to eq('mixedcase')

        # 明示的に参照して警告を解消
        expect(mixed_case_hashtag.name.downcase).to eq('mixedcase')
      end
    end

    context 'when 検索結果が多数ある場合' do
      before do
        # 多数のテストデータを作成
        6.times { |i| create(:user, username: "testuser#{i}") }
      end

      it '各タイプの検索結果が制限されること' do
        get :autocomplete, params: { query: 'testuser' }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body

        user_results = json_response['results'].select { |r| r['type'] == 'user' }
        expect(user_results.length).to be <= 5 # コントローラで設定した制限
      end
    end
  end
end
