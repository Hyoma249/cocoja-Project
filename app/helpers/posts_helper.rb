# 投稿関連のヘルパーメソッドを提供するモジュール
module PostsHelper
  # コンテンツ内のハッシュタグをハイライト表示
  def format_content_with_hashtags(content)
    # 危険なHTMLタグを除去しつつハッシュタグをスタイリング
    content_with_tags = content.gsub(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー]+/) do |tag|
      content_tag(:span, tag, class: 'text-blue-600')
    end

    # 改行をbrタグに変換してエスケープされた状態を保持
    sanitize(content_with_tags, tags: ['span'], attributes: ['class'])
  end
end
