class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  default from:     proc { default_sender_address.format }
  default reply_to: proc { default_reply_to_address.format }

  default charset: "utf-8"
  default content_type: "text/html"

  default_url_options[:host] = "#{Setting.host}"

  private

  def default_sender_address
    address = Mail::Address.new(Setting.smtp_user_name)
    address.display_name = Setting.sender_display_name
    address
  end

  def default_reply_to_address
    address = Mail::Address.new(Setting.reply_email_to)
    address.display_name = Setting.reply_display_name
    address
  end
end
