# frozen_string_literal: true

class QuestionsController < ApplicationController
  include QuestionsAnswers
  before_action :require_authentication, except: %i[show index]
  before_action :set_question!, only: %i[show destroy edit update]
  before_action :authorize_question!
  # проверяет в экшоне права доступа
  after_action :verify_authorized

  def index
    @tags = Tag.where(id: params[:tags_ids]) if params[:tag_ids]
    # метод pagy возвращает массив из двух элементов. передаем объект, который хотим разбить по страницам
    @pagy, @questions = pagy Question.all_by_tags(@tags)
    @questions = @questions.decorate
  end

  def show
    load_question_answers
  end

  def new
    @question = Question.new
  end

  def edit; end

  def create
    # привязка созданного вопроса к определенному пользователю
    @question = current_user.questions.build question_params
    if @question.save
      flash[:success] = 'Question created!'
      redirect_to questions_path
    else
      render :new
    end
  end

  def update
    if @question.update question_params
      flash[:success] = 'Question updated!'
      redirect_to questions_path
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    flash[:success] = t('.success')
    redirect_to questions_path
  end

  private

  def question_params
    # запись для tag_ids означает, что для данной позиции идет целый массив из id и каждый id представляет собой тэг
    params.require(:question).permit(:title, :body, tag_ids: [])
  end

  def set_question!
    @question = Question.find params[:id]
  end

  def authorize_question!
    # метод из pundit
    authorize(@question || Question)
  end
end
