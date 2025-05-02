# アプリケーション全体で使用するヘルパーメソッドを提供するモジュール
module ApplicationHelper
  # ランキングの順位に応じたCSSクラスを返す
  def ranking_badge_class(rank)
    case rank
    when 1
      'bg-yellow-100 text-yellow-800 border-yellow-300' # 金
    when 2
      'bg-gray-100 text-gray-800 border-gray-300' # 銀
    when 3
      'bg-orange-100 text-orange-800 border-orange-300' # 銅
    else
      'bg-gray-50 text-gray-600 border-gray-200' # その他
    end
  end

  # ランキング変動表示用のアイコンを生成
  def rank_change_icon(change)
    return content_tag(:span, 'NEW', class: 'text-indigo-600 text-xs font-medium') if change.nil?

    icon_svg = rank_change_svg(change)
    css_class = rank_change_css_class(change)
    display_change = rank_change_display_value(change)

    content_tag(:span, class: "inline-flex items-center #{css_class}") do
      # sanitizeを使用してSVGを安全に表示
      sanitize(icon_svg) + (display_change.nil? ? '' : content_tag(:span, display_change, class: 'ml-1'))
    end
  end

  # 残りのポイント数に応じたCSSクラスを返す
  def remaining_points_class(points)
    if points.zero?
      'text-red-600'
    elsif points <= 2
      'text-yellow-600'
    else
      'text-green-600'
    end
  end

  private

  # SVGパスだけを返すヘルパーメソッド
  def svg_path_for_change(change)
    if change.positive?
      # 上向き矢印のパス
      'd="M5 10l7-7m0 0l7 7m-7-7v18"'
    elsif change.negative?
      # 下向き矢印のパス
      'd="M19 14l-7 7m0 0l-7-7m7 7V3"'
    else
      # 横線のパス
      'd="M5 12h14"'
    end
  end

  # ランキング変動に応じたSVGを返す
  def rank_change_svg(change)
    path = svg_path_for_change(change)

    '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">' \
      '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" ' \
      "#{path}></path>" \
      '</svg>'
  end

  # ランキング変動に応じたCSSクラスを返す
  def rank_change_css_class(change)
    if change.positive?
      'text-green-600'
    elsif change.negative?
      'text-red-600'
    else
      'text-gray-500'
    end
  end

  # ランキング変動の表示値を返す
  def rank_change_display_value(change)
    # ガード節を使って早期にnilを返す
    return unless change.positive? || change.negative?

    # 変動がある場合は絶対値を返す
    change.abs
  end
end
