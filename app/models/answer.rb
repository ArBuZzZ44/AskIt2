# frozen_string_literal: true

class Answer < ApplicationRecord
  include Commentable

  belongs_to :question
  belongs_to :user

  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags

  validates :body, presence: true, length: { minimum: 5 }
end
