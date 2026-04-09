class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :status, class_name: "Property", optional: true
  belongs_to :record, polymorphic: true
  has_many_attached :files

  validates :content, presence: true

  def file_urls
    self.files.map { |file| Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true) }
  end


  def base_info
    {
      id: self.id,
      content: self.content,
      user_id: self.user_id,
      user_name: (self.user.name rescue ''),
      created_at: self.created_at,
      status_id: self.status_id,
      status_name: (self.status.name rescue ''),
      color: (self.status.color rescue '')
    }
  end
  
end
