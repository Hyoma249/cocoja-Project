# ハッシュタグ関連の機能を提供するヘルパーモジュール
# テキスト中のハッシュタグをリンクに変換したり抽出したりする機能を担当します
module HashtagHelper
  # ハッシュタグをクリック可能なリンクに変換
  def format_content_with_hashtags(content, linkable: true)
    return '' if content.blank?

    # 日本語文字（漢字、ひらがな、カタカナ）も含む正規表現
    pattern = /[#＃]([^\s#＃]+)/

    if linkable
      # リンク付きのハッシュタグ
      result = content.gsub(pattern) do |tag|
        tag_name = ::Regexp.last_match(1)
        link_to tag, "/posts/hashtag/#{tag_name}", class: 'text-blue-600 hover:underline'
      end
      sanitize(result, tags: %w[a], attributes: %w[href class])
    else
      # スタイル付きのハッシュタグ（リンクなし）
      content_with_tags = content.gsub(pattern) do |tag|
        content_tag(:span, tag, class: 'text-blue-600')
      end
      sanitize(content_with_tags, tags: ['span'], attributes: ['class'])
    end
  end

  # ハッシュタグを抽出する
  def extract_hashtags(content)
    return [] if content.blank?

    content.scan(/[#＃]([^\s#＃]+)/).flatten.map(&:downcase).uniq
  end
end
