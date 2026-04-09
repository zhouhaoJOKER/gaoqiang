class Pm::File < ApplicationRecord
    has_ancestry
    # mount_uploader :file, FileUploader

    has_one_attached :file

    # :project_id, :parent_id, :py, :name, :file_size, :color, :user_id, :updater_id, :file_count, :is_public, :kind, :ancestry, :content_type


    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, presence: true
    validates_uniqueness_of :name, :scope => :parent_id

    # before_create :genereate_parent_code
    before_save :gen_py
    # after_create :generate_default_stages

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    
    # belongs_to :company, class_name: "Company", optional: true
    belongs_to :project, class_name: "Pm::Project", optional: true

    belongs_to :parent, class_name: "Pm::File", optional: true

    has_many :children, class_name: "Pm::File", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string


    def base_info
      file_url = ""
      if file.attached?
        begin
          # 设置 ActiveStorage URL 选项
          host = Setting.host rescue nil
          if host.present?
            ActiveStorage::Current.url_options = { host: host }
            file_url = Rails.application.routes.url_helpers.rails_blob_url(file, host: host)
          else
            # 如果没有设置 host，使用相对路径
            file_url = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
          end
        rescue => e
          # 如果生成 URL 失败，返回空字符串
          file_url = ""
          Rails.logger.error "Failed to generate file URL: #{e.message}"
        end
      end
      
      {
        id: id,
        project_id: project_id,
        project_name: (project.name rescue ""),
        parent_id: parent_id,
        parent_name: (parent.name rescue ""),
        name: name,
        py: py,
        url: file_url,
        kind: kind,
        is_public: is_public,
        user_id: user_id,
        user_name: (user.name rescue ""),
        updater_id: updater_id,
        updater_name: (updater.name rescue ""),
        ancestry: ancestry,
        created_at: created_at,
        file_size: file_size,
        content_type: (file.content_type rescue ""),
        children: (children.map{|e|e.base_info} rescue []),
        updated_at: updated_at
      }
    end
    

end
