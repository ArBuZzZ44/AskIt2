class UserBulkImportJob < ApplicationJob
  queue_as :default

  def perform(archive_key, initiator) # то что делается в бэкграунде
    UserBulkImportService.call archive_key

  rescue StandardError => e 
    Admin::UserMailer.with(user: initiator, error: e).bulk_import_fail.deliver_now
  else
    # initiator - тот, кому передаем письмо об  окончании выполнения задачи
    # now т.к. мы уже итак в бэкграунде
    Admin::UserMailer.with(user: initiator).bulk_import_done.deliver_now
  end
end