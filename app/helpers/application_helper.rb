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
    price = Money.from_amount price unless price.is_a? Money
    txt = nontax_price(price)
    txt += separator.html_safe
    txt + tax_price(price)
  end

  def tax_price(price)
    price     = Money.from_amount price unless price.is_a? Money
    new_price = price.exchange_to('EU4TAX').exchange_to('EURTAX')
    content_tag(:span, number_with_delimiter(new_price), class: 'tax', title: 'brutto')
  end

  def display_price_or_content(value, type)
    value = value.to_i if type.to_sym == :content
    number_with_delimiter(value)
  end

  def nontax_price(price, title: 'netto')
    price     = Money.from_amount price unless price.is_a? Money
    new_price = price.exchange_to('EU4NET').exchange_to('EURNET')
    content_tag(:span, number_with_delimiter(new_price), class: 'nontax', title: title)
  end

  def list_link(url)
    link_to fa_icon('chevron-left', text: t(:list)), url, class: 'btn btn-default'
  end

  def new_link(url, primary: true, label: t(:new), options: {})
    css = primary ? 'btn btn-primary' : 'btn btn-default'
    options[:class] = css + ' hidden-print'
    link_to fa_icon('plus', text: label), url, options
  end

  def edit_link(url)
    link_to fa_icon('pencil', text: t(:edit)), url, class: 'btn btn-primary'
  end

  def pdf_link(url)
    link_to fa_icon('file-pdf-o', text: 'PDF'), url, class: 'btn btn-default', target: '_blank'
  end

  def delete_link(record)
    label = fa_icon 'trash', text: t(:delete)
    confirm = t(:confirm_delete, model: record.class.model_name.human)
    link_to label, record, method: :delete, data: { confirm: confirm }, class: 'btn btn-danger'
  end

  def title_for(model_or_record, attr = nil)
    title = if model_or_record.is_a? ActiveRecord::Base
      title_for_record model_or_record, attr
    else
      title_for_model model_or_record, attr
    end
    content_for :title, title
  end

  def title_for_record(record, attr = nil)
    attr ||= :id
    id = attr.is_a?(Symbol) ? record.send(attr) : attr
    t("#{record.class.model_name.name.tableize}.single.title", id: id)
  end

  def title_for_model(model, attr = nil)
    if attr
      t("#{model.model_name.name.tableize}.#{attr}.title")
    else
      model.model_name.human count: 2
    end
  end
end
