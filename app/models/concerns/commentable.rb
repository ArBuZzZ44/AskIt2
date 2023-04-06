# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    # к любой модели можем подключить этот concern и у этой модели будет много комментариев
    # и эти виртуальные отношения будут называться commentable
    has_many :comments, as: :commentable, dependent: :destroy
  end
end
