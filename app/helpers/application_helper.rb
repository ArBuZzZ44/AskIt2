# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def pagination(obj)
    pagy_bootstrap_nav(obj) if obj.pages > 1
  end

  def nav_tab(title, url, options = {})
    current_page = options.delete :current_page

    # если заголовк равен текущей странице, то text-secondary
    css_class = current_page == title ? 'text-secondary' : 'text-white'

    options[:class] = if options[:class]
                        "#{options[:class]} #{css_class}"
                      else
                        css_class
                      end

    link_to title, url, options
  end

  def currently_at(current_page = '')
    # значение current_page, которая передается методу, дожна передоваться локальной переменной current_page:
    render partial: 'shared/menu', locals: { current_page: }
    # пишем именно partial, т.к. может вывести и partial и layout
  end

  def full_title(page_title = '')
    base_title = 'AskIt'
    if page_title.present?
      "#{page_title} | #{base_title}"
    else
      base_title
    end
  end
end
