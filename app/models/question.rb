# frozen_string_literal: true

class Question < ApplicationRecord
  include Commentable

  has_many :answers, dependent: :destroy # если удалить question, то все зависимые ответы тоже долнжы удалиться
  belongs_to :user

  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags

  validates :title, presence: true, length: { minimum: 2 }
  validates :body, presence: true, length: { minimum: 2 }
end
