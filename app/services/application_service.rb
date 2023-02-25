class ApplicationService
  def self.call(*args, &block)
    new.(*args, &block).call # инстанцирует указанный класс и вызывает метод
  end
end