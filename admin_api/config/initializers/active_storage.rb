# 全局禁用AWS SDK的EC2实例元数据服务和其他默认凭证提供程序
Aws.config.update({
  credentials_provider: nil,
  ec2_metadata_service_endpoint: nil,
  ec2_instance_metadata_endpoint: nil,
  sts_endpoint: nil
})

Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy

# 确保active_storage.services存在
Rails.application.config.active_storage.services ||= ActiveSupport::OrderedOptions.new

# 先配置基本的local服务
Rails.application.config.active_storage.services[:local] = {
  service: "Disk",
  root: Rails.root.join("storage"),
  public: true
}

# 在应用初始化完成后配置S3服务
Rails.application.config.after_initialize do
  # 动态配置s3服务
  begin
    # 动态获取s3配置，转换为普通Hash以确保兼容性
    s3_settings = Setting.s3.is_a?(ActionController::Parameters) ? Setting.s3.to_unsafe_h : Setting.s3
    
    # 确保endpoint有正确的协议
    endpoint = s3_settings[:endpoint]
    if endpoint.present?
      endpoint = endpoint.start_with?('http://', 'https://') ? endpoint : "http://#{endpoint}"
      Rails.logger.info "DEBUG_S3_CONFIG: Validated endpoint = #{endpoint}"
    else
      Rails.logger.info "DEBUG_S3_CONFIG: No endpoint provided, using default S3 endpoint"
    end
    
    # 只包含必要的S3配置字段，并确保所有必填字段都有合理的默认值
    credentials = Aws::Credentials.new(
      s3_settings[:access_key_id].presence || '',
      s3_settings[:secret_access_key].presence || ''
    )

    s3_config = {
      service: "S3",
      credentials: credentials,
      credentials_provider: nil,
      region: s3_settings[:region].presence || 'us-east-1',
      bucket: s3_settings[:bucket].presence || '',
      endpoint: endpoint.presence || 'http://localhost:9000',
      force_path_style: true
    }
    
    # 更新s3服务配置
    Rails.application.config.active_storage.services[:s3] = s3_config
  rescue => e
    Rails.logger.error "Failed to configure S3 service: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # 配置失败时使用最小化的s3服务配置
    credentials = Aws::Credentials.new('', '')
    Rails.application.config.active_storage.services[:s3] = {
      service: "S3",
      credentials: credentials,
      credentials_provider: nil,
      region: "us-east-1",
      force_path_style: true
    }
  end
end

# 移除覆盖的service_name方法，让Blob使用实际设置的service_name

# 在应用初始化完成后设置URL选项
Rails.application.config.after_initialize do
  ActiveStorage::Current.url_options = {host: Setting.host}
end
