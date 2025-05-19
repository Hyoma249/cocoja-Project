class SearchController < ApplicationController
  def autocomplete
    query = params[:query].to_s.strip.downcase

    if query.blank?
      render json: { results: [] }
      return
    end

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

    results = users + prefectures + hashtags

    render json: { results: results }
  end
end
