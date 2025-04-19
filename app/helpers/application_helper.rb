module ApplicationHelper
  def ranking_badge_class(rank)
    case rank
    when 1
      "bg-yellow-100 text-yellow-800 border-yellow-300"  # 金
    when 2
      "bg-gray-100 text-gray-800 border-gray-300"      # 銀
    when 3
      "bg-orange-100 text-orange-800 border-orange-300"  # 銅
    else
      "bg-gray-50 text-gray-600 border-gray-200"       # その他
    end
  end

  def rank_change_icon(change)
    if change.nil?
      return content_tag(:span, "NEW", class: "text-indigo-600 text-xs font-medium")
    end

    if change > 0
      icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 10l7-7m0 0l7 7m-7-7v18"></path></svg>'
      css_class = "text-green-600"
    elsif change < 0
      icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"></path></svg>'
      css_class = "text-red-600"
      change = change.abs
    else
      icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14"></path></svg>'
      css_class = "text-gray-500"
      change = nil
    end

    content_tag(:span, class: "inline-flex items-center #{css_class}") do
      raw(icon) + (change.nil? ? "" : content_tag(:span, change, class: "ml-1"))
    end
  end

  def remaining_points_class(points)
    if points == 0
      "text-red-600"
    elsif points <= 2
      "text-yellow-600"
    else
      "text-green-600"
    end
  end
end
