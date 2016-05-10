module ApplicationHelper

  def lines_for(values)
    values.select(&:present?).join('<br>').html_safe
  end

  def gmaps_link(obj)
    ['https://maps.google.de?q=', obj.street, obj.zip, obj.city].join(' ')
  end

  def bool_icon(val, yes_title = 'yes', no_title = 'no')
    label, icon, title = case val
    when true then ['success', 'ok-sign', yes_title]
    when false then ['danger', 'minus-sign', no_title]
    else ['default', 'minus-sign', '']
    end

    content_tag :span, class: 'label label-' + label, title: title do
      content_tag :span, nil, class: 'glyphicon glyphicon-' + icon
    end
  end

  def ldate(date, options = nil)
    return '' unless date.present?
    l date, options
  end

  def panel_box(title: nil, css_class: '', &block)
    content = capture(&block)
    content_tag(:div, class: "panel panel-default #{css_class}") do
      head = panel_heading title:   title
      body = content_tag(:div, content, class: 'panel-body')
      [head, body].join.html_safe
    end
  end

  def panel_box_with_table(title: nil, css_class: '', &block)
    content = capture(&block)
    content_tag(:div, class: "panel panel-default #{css_class}") do
      head = panel_heading title:   title
      [head, content].join.html_safe
    end
  end

  def panel_heading(title: nil)
    return unless title
    content_tag(:div, class: 'panel-heading') { content_tag(:h4, title, class: 'panel-title') }
  end

  def display_price(price, separator: '<br>')
    txt = content_tag(:span, price.exchange_to('EU4NET'), class: 'nontax', title: 'netto')
    txt += separator.html_safe
    txt + content_tag(:span, price.exchange_to('EU4TAX'), class: 'tax', title: 'brutto')
  end

end
