
#
# config/initializers/scheduler.rb

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton

return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'


# 初始化log
logger = my_custom_logger()

# do not schedule when Rails is run from its console, for a test/spec, or
# from a Rake task

scheduler.every '24h' do
  logger.info "====== 开启定期检查, #{Time.now}"
  # logger.info  Sy::Service.where.not(is_open: false).size

  # Sy::Service.where.not(is_open: false).each do |service|
  #   # logger.info service.id
  #   service.check_is_alarm
  # end
  Rails.logger.flush
end

# scheduler.cron '1 0 * * *' do
#   # do something every day, five minutes after midnight
#   # (see "man 5 crontab" in your terminal)
#   System.auto_backup_mysql_and_mail
#   System.auto_log_backup
#   System.restart
  
# end

# scheduler.cron "1   #{Setting.huifang_wx_webhook_send_at} * * *" do
#   p "huifang_timeout_wx_notify"
#   Fm::Contract.huifang_timeout_wx_notify
#   p "huifang_timeout_wx_notify"
# end

# scheduler.cron "00   #{Setting.opportunity_huifang_wx_webhook_send_at} * * *" do
#   p "opportunity_huifang_timeout_wx_notify"
#   Crm::Opportunity.opportunity_huifang_timeout_wx_notify
#   p "opportunity_huifang_timeout_wx_notify"
# end


# scheduler.cron "29   09 * * *" do
#   p "0929 check_unfinshed_audits"
#   Oa::AuditLog.check_unfinshed_audits
#   p "0929 check_unfinshed_audits"
# end

# scheduler.cron "29   16 * * *" do
#   p "1629 check_unfinshed_audits"
#   Oa::AuditLog.check_unfinshed_audits
#   p "1629 check_unfinshed_audits"
# end


# scheduler.every '2h' do
#   logger.info "====== 开启定期检查, #{Time.now}  check_is_upload_jianguoyun"
#   Oa::Approval.check_is_upload_jianguoyun
#   Rails.logger.flush
# end

# scheduler.every '2.m' do
#   logger.info "#1>>>>> 每两分钟校验消息发送情况 : #{Time.now}"
#   msgs = Message.today.fail
#   if msgs.present?
#     msgs.map do |e|
#       e.resend_msg
#     end
#   end
# end


