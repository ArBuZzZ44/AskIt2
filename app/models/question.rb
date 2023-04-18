# frozen_string_literal: true

class Question < ApplicationRecord
  include Commentable
  include Authorship

  has_many :answers, dependent: :destroy # если удалить question, то все зависимые ответы тоже долнжы удалиться
  belongs_to :user

  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags

  validates :title, presence: true, length: { minimum: 2 }
  validates :body, presence: true, length: { minimum: 2 }

  # scope - метод класса, который мы можем вызвать(работает как def self.___)
  scope :all_by_tags, lambda { |tag_ids|
    questions = includes(:user, :question_tags, :tags)
    # делаем связку в sql с таблицей тэгов, где tags это tag_ids но только если tag_ids присутствует
    questions = questions.joins(:tags).where(tags: tag_ids) if tag_ids
    questions.order(created_at: :desc)
  }
end
