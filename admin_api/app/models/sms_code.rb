class SmsCode < ApplicationRecord
  scope :sended, -> {where("created_at > ?", Time.now-5.minutes)}

  def skip_generate_code?
  # 返回 true 或false来决定是否跳过回调
      false # 或者 false 根据条件判断
  end


  # TODO 发送短信验证码功能实现 
  # SmsCode.send_sms(2,"",123456)
  def self.send_sms(user_id, phone, code)
    p "code"*100
    p code
    enc_code = System.en64(code)
    p enc_code
    p "code"*100
    SmsCode.create(
      user_id: user_id,
      code: enc_code,
    )
  end

  # SmsCode.last.real_code
  def real_code
    System.de64(code)
  end
  
end
