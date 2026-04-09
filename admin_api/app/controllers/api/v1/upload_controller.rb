require "active_storage/service/s3_service"
require "active_storage/service/disk_service"

class Api::V1::UploadController < Api::V1::BaseController
  before_action :check_authorize, except: [ :upload_test ]

  def wangeditor
    file = params[:file]

    data = {
      file: file,
      name: file.original_filename,
      content_type: file.content_type,
      byte_size: file.size,
      user_id: @current_user.id
    }

    @attachment = Attachment.new(data)
    if  params[:global_id].present?
      record = GlobalID::Locator.locate params[:global_id]
      record.record = record if record.present?
    end

    if @attachment.save
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "上传文件成功")
      render json: {
        code: 200,
        errno: 0, 
        success: 1,
        msg: t("create_success"),
        url: @attachment.file.url,
        data: {
          "url": Setting.host+@attachment.file.url,
          "alt": "这是一张示例图片",
          "href":  Setting.host+@attachment.file.url
        }
      }
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "上传文件失败")
      render json: { code: 500, success: 0, msg: @node.errors.full_messages.join(","), data: "" }
    end
  end
  

  # 基础文件上传，使用carrierwave上传文件
  # post api/v1/basic_upload
  def basic_upload
    file = params[:file]
    begin
      data = {
        file: file,
        name: file.original_filename,
        content_type: file.content_type,
        byte_size: file.size,
        user_id: @current_user.id
      }

      @attachment = Attachment.new(data)
      if  params[:global_id].present?
        record = GlobalID::Locator.locate params[:global_id]
        record.record = record if record.present?
      end

      if @attachment.save
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "上传文件成功")
        render json: {
          code: 200,
          success: 1,
          msg: t("create_success"),
          url: @attachment.file.url,
          data: @attachment.base_info
        }
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "上传文件失败")
        render json: { code: 500, success: 0, msg: @node.errors.full_messages.join(","), data: "" }
      end
    rescue => e
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "上传文件失败")
      render json: { code: 500, success: 0, msg: "上传文件失败: #{e.message}", data: "" }
    end
  end

  def upload
    file = params[:file]
    record = ""
    record = GlobalID::Locator.locate params[:global_id] if  params[:global_id].present?
    perform_upload(file, record)
  end

  def upload_test
    file = params[:file]
    perform_upload(file)
  end

  private
  def create_storage_service(service_name)
    if service_name == "s3"
      s3_settings = Setting.s3.is_a?(ActionController::Parameters) ? Setting.s3.to_unsafe_h : Setting.s3

      endpoint = s3_settings[:endpoint]
      endpoint = endpoint.start_with?("http://", "https://") ? endpoint : "http://#{endpoint}" if endpoint.present?

      credentials = Aws::Credentials.new(
        s3_settings[:access_key_id],
        s3_settings[:secret_access_key]
      )

      s3_config = {
        credentials: credentials,
        region: s3_settings[:region] || "us-east-1",
        bucket: s3_settings[:bucket],
        endpoint: endpoint,
        force_path_style: true
      }
      service = ActiveStorage::Service::S3Service.new(**s3_config)

      # Rails.logger.info "#{self.class.name}:#{__method__}: Created S3 service object with endpoint = #{endpoint}"
      service
    else
      local_config = {
        root: Rails.root.join("storage/#{Setting.storage_prefix}"),
        public: true
      }

      service = ActiveStorage::Service::DiskService.new(**local_config)

      # Rails.logger.info "#{self.class.name}:#{__method__}: Created local service object"
      service
    end
  end

  def upload_file(file, service_name)
    file_content = file.read
    file.rewind  # 重置文件指针
    checksum = Digest::SHA256.base64digest(file_content)
    # Rails.logger.info "#{self.class.name}:#{__method__}: Calculated checksum #{checksum} for file #{file.original_filename}"
    service = create_storage_service(service_name)
    blob = ActiveStorage::Blob.create!(filename: file.original_filename, content_type: file.content_type, byte_size: file.size, checksum: checksum, service_name: "local", metadata: { filename: file.original_filename, content_type: file.content_type })
    Rails.logger.info "#{self.class.name}:#{__method__}: Created blob with key = #{blob.key}, service_name = #{service_name}"
    service.upload(blob.key, StringIO.new(file_content), content_type: blob.content_type)
    # Rails.logger.info "#{self.class.name}:#{__method__}: Uploaded file using #{service.class.name}"
    blob.update_column(:service_name, service_name)
    # Rails.logger.info "#{self.class.name}:#{__method__}: Updated blob service_name to #{service_name}"
    blob
  end

  def perform_upload(file, record = "", options = {})
    # 根据配置动态指定service_name
    service_name = Setting.storage_service == "s3" ? "s3" : "local"
    # 使用公共方法上传文件
    begin
      blob = upload_file(file, service_name)
      # 处理关联记录
      unless record.present?
        # 准备数据
        data = {
          name: file.original_filename,
          content_type: file.content_type,
          byte_size: file.size,
          user_id: 1 # 测试用户
        }
        record = Attachment.create(data)
      end
      # 关联blob到记录
      # record.files.attach(blob)
      # 记录日志
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "上传文件#{file.original_filename}成功")
      # 直接创建ActiveStorage::Attachment记录，避免使用attach方法
      attachment = ActiveStorage::Attachment.create!(record: record, name: :files, blob: blob)
      # 准备响应数据
      response_data = {
        code: 200,
        success: 1,
        msg: t("create_success"),
        data: record,
        service_name: service_name,
        attachment: attachment,
        storage_service: service_name
      }
      # 添加可选的blob_id
      response_data[:blob_id] = blob.id if options[:include_blob_id]
      render json: response_data
    rescue => e
      blob&.purge
      # 记录日志
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "上传文件#{file.original_filename}失败:#{e.message}")
      render json: {
        code: 500,
        success: 0,
        msg: "Failed to create attachment: #{e.message}",
        data: ""
      }
    end
  end

  def check_authorize
    begin
      authorize!(params[:action].to_sym, Attachment)
    rescue CanCan::AccessDenied
      render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
    end
  end
end
