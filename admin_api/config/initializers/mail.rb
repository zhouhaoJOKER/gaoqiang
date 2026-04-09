Rails.application.config.action_mailer.delivery_method =  ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
    address: Setting.smtp_address,
    port: Setting.smtp_port,
    user_name: Setting.smtp_user_name,
    password: Setting.smtp_password,
    domain: Setting.smtp_domain,
    authentication: Setting.smtp_authentication,
    # enable_starttls_auto: Setting.smtp_enable_ssl,
    ssl: Setting.smtp_enable_ssl,
    :openssl_verify_mode => 'none'
}
  
Rails.application.config.hosts << ::Setting.default_host

Rails.application.config.action_mailer.default_url_options  = { host: Setting.default_host }





def my_custom_logger(file_name="scheduler.log")
  logger = Logger.new("#{Rails.root}/log/#{file_name}")
  logger.level = Logger::DEBUG  # 设置日志的level
  logger.formatter = proc do |severity, datetime, progname, message| # 设置日志的formatter
    "[#{Time.now.to_fs(:db)}]  #{message}\n"
  end
  logger
end