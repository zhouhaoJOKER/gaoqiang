class HomeController < ApplicationController
  # skip_before_action :verify_authenticity_token, :current_ip_is_locked, :check_visit_logs, only: [:xxx]
  layout "mailer" , only: :not_find
  # skip_before_action :check_base_authenticate, only: [:xxx]

  def menu
  end

  def user_list
    
  end
  
  def site_info
    render json: {
        "code": 200,
        "data": {
          "host": Setting.host,  #系统地址
          "name": Setting.app_name,  #系统名称
          "slogan": Setting.slogan,  #系统标语
          "titleName": Setting.title_name,  #系统标题
          openCaptcha: Setting.open_captcha,  #是否开启验证码
          authorName: Setting.author_name,  #认证系统名称
          authorUrl: Setting.author_url,  #认证系统地址
          logo: Setting.logo,  #系统Logo地址
          favicon: Setting.favicon,  #系统ICON地址
          icp: Setting.icp,  #ICP 备案号
          policeCode: Setting.police_code,  #公安备案号
          versionCode: Setting.version_code,  #系统版本号
        }
      }
  end


  def not_find
    now = System.now_s
		render :json => {
			code: 404,
			data: now,
			msg: "ok",
    },:status => 404
  end


  def ping
    render :json => {"ping":0,"code":200,"success":1,"ip": @current_ip,"msg":"success!"}
  end

  def version
    render json: {"code":200,"success":1,"msg":"ok","api_version":"V1.0"}
  end
  
  

  def cached
    cache_file = Rails.root.join('tmp', 'caching-dev.txt')
    online_user_count_file = Rails.root.join('tmp', 'online_user_count')
    if params[:state] == "open"
      system("touch #{cache_file}")
      system("touch #{online_user_count_file}")
      redirect_to "/", notice:  "开启缓存成功"
    elsif params[:state] == "close"
      system("rm #{cache_file}")
      system("rm #{online_user_count_file}")
      redirect_to "/", notice:  "关闭缓存成功"
    end
  end
  
end
