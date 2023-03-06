# frozen_string_literal: true

module QuestionsAnswers
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    def load_question_answers(do_render: false)
      @question = @question.decorate
      # если answer уже есть, то ничего не делать, если его нет, то создается
      @answer ||= @question.answers.build
      @pagy, @answers = pagy @question.answers.order(created_at: :desc)
      @answers = @answers.decorate
      render('questions/show') if do_render
    end

  end
end