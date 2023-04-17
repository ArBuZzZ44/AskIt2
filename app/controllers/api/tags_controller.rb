module Api
  class TagsController < ApplicationController
    def index
      tags = Tag.arel_table # arel позволяет строить более сложные sql запросы
      # обозначает, что хочу найти заголовок, в котором содержится слово в парамс
      @tags = Tag.where(tags[:title].matches("%#{params[:term]}%"))

      # render выполнит сериализацию и превратит коллекцию тэгов в json
     render json: TagBlueprint.render(@tags)
    end
  end
end