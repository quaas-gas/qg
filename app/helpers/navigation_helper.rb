module NavigationHelper

  def navbar(options)

  end

  def dropdown_title(title)
    content_tag :a, href: '#', class: 'dropdown-toggle', role: 'button', tabindex: -1, aria: {expanded: 'false', hashpopup: 'true'}, data: {toggle: 'dropdown'} do
      "#{title} <span class='caret'></span>".html_safe
    end.html_safe
  end

  def navbar_dropdown(title, active: false, &block)
    css_class = [:dropdown]
    css_class << :active if active
    content_tag :li, class: css_class do
      dropdown_title(title) +
        content_tag(:ul, class: 'dropdown-menu', &block)
    end
  end
end
