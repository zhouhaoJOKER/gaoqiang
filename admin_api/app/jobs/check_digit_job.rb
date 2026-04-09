class CheckDigitJob < ApplicationJob
  #queue_as :solid_queue
  self.queue_adapter = :solid_queue


  def perform(record, check_digit)
    # Do something later
    # p record
    # p record.id
    record.update_columns(check_digit: check_digit)
  end
end
