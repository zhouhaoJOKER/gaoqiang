class SendMailer < ApplicationMailer
  # 邮件测试
  # SendMailer.test('cxhyun@126.com',"mail test", "contentcontent").deliver
  def test(email, subject, info="空")
    return false if email.blank?
    @mail ={
      email: email,
      subject: subject,
      info: info
    }
    mail(to: email, subject: subject )
  end

  # 重置密码邮件
  # SendMailer.reset_password_mail('cxhyun@126.com',"mail test", "contentcontent").deliver
  def reset_password_mail(user)
    return false if user.blank?
    subject = "【#{Setting.app_name}】密码重置邮件"
    @mail ={
      email: user.email,
      subject: subject,
      name: user.name,
      url: "#{Setting.host}/#/auth/reset-password?token=#{user.reset_password_token}"
    }
    mail(to: user.email, subject: subject )
  end

  # 激活账号邮件
  # SendMailer.confirmation_mail('cxhyun@126.com',"mail test", "contentcontent").deliver
  def confirmation_mail(user)
    return false if user.blank?
    subject = "【#{Setting.app_name}】账号激活邮件"
    @mail ={
      email: user.email,
      subject: subject,
      name: user.name,
      url: "#{Setting.host}/#/auth/confirm-mail?token=#{user.confirmation_token}"
    }
    mail(to: user.email, subject: subject )
  end

  # 邮件测试
  # SendMailer.backup_file('cxhyun@126.com',"/home/chenwei/project/contract/tmp/cache/1615565045.515913.sql.tar.gz").deliver
  def backup_file(email, file_path)
    return false if email.blank?
    p file_path
    attachments['sql.tar.gz'] = File.read(file_path)
    @mail ={
      email: email,
    }
    mail(to: email, subject: "【#{Date.today.strftime('%Y-%m-%d')}】数据库备份完成！" )
  end
  
  # attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
  # SendMailer.welcome_email('cxhyun@126.com',"mail test", "contentcontent").deliver
  def welcome_email(email, subject, info="空")

    delivery_options = { user_name: "cxhyun@163.com",
                         password: "xxx",
                         address: "smtp.163.com" }
    p delivery_options
    @mail ={
      email: email,
      subject: subject,
      info: info
    }
    mail(to: email,
         subject: subject,
         delivery_method_options: delivery_options)
  end
end
