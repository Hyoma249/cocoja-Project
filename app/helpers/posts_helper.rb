module PostsHelper
  # ハッシュタグをクリック可能なリンクに変換し、改行も適切に処理する
  def format_content_with_hashtags(content)
    return '' if content.blank?

    # 日本語文字（漢字、ひらがな、カタカナ）も含むハッシュタグの正規表現
    pattern = /[#＃]([^\s#＃]+)/

    # まずハッシュタグを処理する
    formatted_content = content.gsub(pattern) do |tag|
      tag_name = ::Regexp.last_match(1)
      link_to tag, "/posts/hashtag/#{tag_name}", class: 'text-blue-600 hover:underline'
    end

    # 改行をHTMLの<br>タグに変換
    formatted_content = formatted_content.gsub(/\r\n|\r|\n/, "<br>")

    # 安全なHTMLとして返す
    sanitize(formatted_content, tags: %w[a br], attributes: %w[href class])
  end

  # ハッシュタグを抽出する
  def extract_hashtags(content)
    return [] if content.blank?

    content.scan(/[#＃]([^\s#＃]+)/).flatten.map(&:downcase).uniq
  end

  # リンクなしでハッシュタグをスタイルだけ適用する（必要に応じて）
  def format_content_without_links(content)
    return '' if content.blank?

    pattern = /[#＃]([^\s#＃]+)/

    # スタイル付きのハッシュタグ（リンクなし）
    content_with_tags = content.gsub(pattern) do |tag|
      content_tag(:span, tag, class: 'text-blue-600')
    end

    # 改行をHTMLの<br>タグに変換
    content_with_tags = content_with_tags.gsub(/\r\n|\r|\n/, "<br>")

    sanitize(content_with_tags, tags: ['span', 'br'], attributes: ['class'])
  end
end
