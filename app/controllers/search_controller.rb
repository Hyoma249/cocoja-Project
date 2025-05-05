# SearchControllerは、オートコンプリート機能を含む検索関連のアクションを処理します
class SearchController < ApplicationController
  # 検索候補を返すAPIエンドポイント
  def autocomplete
    # パラメータから検索キーワードを取得
    query = params[:query].to_s.strip.downcase

    # 空の検索の場合は空の結果を返す
    if query.blank?
      render json: { results: [] }
      return
    end

    # 検索対象のモデルから該当するデータを取得
    # 例: ユーザー、都道府県、ハッシュタグから検索
    users = User.where('username LIKE ? OR uid LIKE ?', "%#{query}%", "%#{query}%")
                .limit(5)
                .map do |u|
                  {
                    id: u.id,
                    text: u.username,
                    type: 'user',
                    image: u.profile_image_url.url,
                    url: user_path(u)
                  }
                end

    prefectures = Prefecture.where('name LIKE ?', "%#{query}%")
                            .limit(5)
                            .map { |p| { id: p.id, text: p.name, type: 'prefecture', url: posts_prefecture_path(p) } }

    hashtags = Hashtag.where('name LIKE ?', "%#{query}%")
                      .limit(5)
                      .map { |h| { id: h.id, text: h.name, type: 'hashtag', url: hashtag_posts_path(h.name) } }

    # 結果を結合して返す
    results = users + prefectures + hashtags

    render json: { results: results }
  end
end
