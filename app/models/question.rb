# frozen_string_literal: true

class Question < ApplicationRecord
  has_many :answers, dependent: :destroy # если удалить question, то все зависимые ответы тоже долнжы удалиться
  belongs_to :user
  
  validates :title, presence: true, length: { minimum: 2 }
  validates :body, presence: true, length: { minimum: 2 }
end
