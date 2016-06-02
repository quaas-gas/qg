module DeliveriesHelper

  def format_delivery_item_count(item)
    return '' unless item
    diff      = item.count - item.count_back
    css_class = { -1 => 'text-danger', 1 => 'text-success' }[diff <=> 0]
    res       = "#{item.count} / #{item.count_back}"
    diff_text = diff == 0 ? '-' : diff

    content_tag(:span, "#{res} #{diff_text}", class: css_class).html_safe
  end
end
