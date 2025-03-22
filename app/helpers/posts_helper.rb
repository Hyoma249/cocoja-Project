module PostsHelper
  def format_content_with_hashtags(content)
    content.gsub(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー]+/) do |tag|
      "<span class='text-blue-600'>#{tag}</span>"
    end.html_safe
  end
end
