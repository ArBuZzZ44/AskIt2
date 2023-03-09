class CommentDecorator < ApplicationDecorator
  delegate_all
  decorates_association :user

  # определяем, для вопроса или ответа комментарий
  def for?(commentable)
    # если commentable задекорирован, то берем оттуда конкретный образер класса
    commentable = commentable.object if commentable.decorated?
    commentable == self.commentable
  end
end