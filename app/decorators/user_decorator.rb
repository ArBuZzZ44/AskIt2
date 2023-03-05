# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate_all # данная строка нужна, чтобы делегировать
  # неизвестные методы самому объекту, который мы декорируем.
  # декараторы нужны для добавления к существующим объектам
  # каких-либо дополнительных методов, эти методы включают в себя логику,
  # связанную с отображением этого объекта. эти методы не живут
  # в глобальном пространстве имен, как хелперы, а только для данных объектов

  def name_or_email
    (name.presence || email.split('@')[0])
  end

  def gravatar(size: 30, css_class: '')
    # генерируем адрес изображения, h означает, что используем хелпер rails
    h.image_tag "https://www.gravatar.com/avatar/#{gravatar_hash}.jpg?s=#{size}",
                class: "rounded #{css_class}", alt: name_or_email
  end
end
