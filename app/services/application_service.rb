# frozen_string_literal: true

class ApplicationService
  def self.call(...)
    new(...).call # инстанцирует указанный класс и вызывает метод
  end
end
