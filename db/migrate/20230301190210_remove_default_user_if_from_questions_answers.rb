class RemoveDefaultUserIfFromQuestionsAnswers < ActiveRecord::Migration[7.0]
  # применяется при применении миграции
  def up
    # чтобы поменять значение лучше использовать from - to
    change_column_default :questions, :user_id, from: User.first.id, to: nil
    change_column_default :answers, :user_id, from: User.first.id, to: nil
  end

  # применяется при откате миграции
  def down
    change_column_default :questions, :user_id, from: nil, to: User.first.id
    change_column_default :answers, :user_id, from: nil, to: User.first.id
  end
end
