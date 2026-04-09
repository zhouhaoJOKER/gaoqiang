require 'rest-client'

class SyncAuditContract < ApplicationJob
  #queue_as :solid_queue
  self.queue_adapter = :solid_queue

# SyncAuditContract.perform_later(path, task_id)
  def perform(path, task_id, api_url)
    result = RestClient.post api_url, 
     {:file => File.new(path, 'rb'), :task_id => task_id, :multipart => true}
    p result.to_json
  end
end
