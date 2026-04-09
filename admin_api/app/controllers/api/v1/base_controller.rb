require 'csv'

module Api
  module V1
    class BaseController < ActionController::API

      before_action :set_current_ip
      before_action :check_visit_restriction

      before_action :set_current_user

      def check_folder
        path ="#{Rails.root}/public/uploads"
        path = Rails.root.join('public/', "uploads") if Rails.env == "development" 
        if File.exist?(path)
        else
          system("mkdir -p #{path}")
        end
        return path
      end
      

      
      #导出检验统计报表
      def export_task_summary(data,label="项目通过率统计表")
        path = check_folder
        filename = "#{Setting.app_abbr}#{label}-#{Time.now.strftime('%Y%m%d%H%M')}.csv"
        csv_file = "#{path}/#{filename}"
        File.open("#{csv_file}","w+:gbk") do |f|
            dkeyss = data[0].keys rescue ''
            size = dkeyss.length
            f.puts dkeyss.join(",") rescue ''
            data.each do |single|
                o = ""
                dkeyss.each do |kk|
                    o << "#{single[kk]}, "
                end
                a =  "#{o} ,\n"
                f.puts a
            end if dkeyss.present?
            f.close
        end
        ts= System.now_s
        System.zip_file("#{path}/#{filename}", "#{path}/#{filename}.zip")
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "导出#{label}")
        render json: {code: 200, success: 1 , msg: "ok",   data: [{url: "/uploads/#{filename}.zip" }] }
      end

      # 生成导出excel流
      def gen_export_excel_stream(data, columns, i18n_column_names = nil)
        sheet =  Axlsx::Package.new
        sheet.workbook do |wb|
        styles = wb.styles
        title = styles.add_style :sz => 18, :b => true, :u => true, alignment: { horizontal: :center }
        default = styles.add_style fg_color: '00', sz: 12, alignment: { horizontal: :left }
        header = styles.add_style :bg_color => '145b7d', sz: 12, :fg_color => 'FFF', :b => true, alignment: { horizontal: :left }
          s = wb.styles
          wrap_text = s.add_style alignment: { wrap_text: true }
          wb.add_worksheet(name: 'Data') do |ws|
            if i18n_column_names.present?
              ws.add_row i18n_column_names, :style => header
            end
            ws.add_row columns, :style => header

            data.each do |item|
            values = columns.map{|e| (eval("item.#{e}")  rescue '')}
              ws.add_row values, :style => default
            end
            letter =System.calculate_letter(columns.size)
            # ws.merge_cells "A1:#{letter}1"
            # ws.auto_filter = "A1:#{letter}#{columns.size+1}"
          end
          excel_stream = sheet.to_stream.read
          return excel_stream
        end
      end

      # 生成导出excel流
      def gen_export_xlsx_file(data, columns, i18n_column_names = nil)
        filename="/uploads/tmp/export_template_#{System.now_s}.xlsx"
        file = "#{Rails.root}/public/#{filename}"
        # file = Tempfile.new(['export_template_', '.xlsx'], Rails.root.join('public','uploads','tmp'))

        excel_stream = gen_export_excel_stream(data, columns, i18n_column_names)
        # 二进制模式写入
        File.binwrite(file, excel_stream)
          
        return file
      end

      # 生成导出excel流
      def gen_export_csv_file(data, columns, i18n_column_names = nil)
          filename="/uploads/tmp/export_template_#{System.now_s}.csv"
          file = "#{Rails.root}/public/#{filename}"
          CSV.open(file, "wb") do |csv|
            csv << i18n_column_names if i18n_column_names.present?
            csv << columns
            data.each do |item|
            csv << item.attributes.values_at(*columns)
            end if data.present?
          end
        return file
      end
          

      def current_user
        @current_user
      end

      private

        #####################  日志生成  #####################
        # 生成安全日志
        def gen_security_log(user_id, ip,  event, success, describe="",  modules="")
          Log.generate_log(20, user_id, ip, describe, event, success, modules)
        end

        # 生成审计日志
        def gen_audit_log(user_id, ip,  event, success, describe="",  modules="")
          Log.generate_log(30, user_id, ip, describe, event, success, modules)
        end

        # 生成登录日志
        def gen_login_log(user_id, ip,  event, success, describe="",  modules="")
          Log.generate_log(0, user_id, ip, describe, event, success, modules)
        end

        # 生成操作日志
        def gen_log(user_id, ip,  event, success, describe="",  modules="")
          Log.generate_log(10, user_id, ip, describe, event, success, modules) if Setting.open_security_certificate || Setting.open_log
        end

        #####################  判断黑白名单  #####################
        def set_current_ip
          @current_ip = eval("#{Setting.get_request_ip}")
          if Setting.open_security_certificate
            check_blacklists
            check_whitelists
            if Setting.open_check_digit
              #p "*"*10+" 校验位检查开始 " +"*"*10
              #p "接收到校验位值：" + params[:check]
              data = params[:check].split(".")[1]
              # #p "解密后校验位值：" + (Base64.decode64(data) rescue '')
              # #p "当前时间戳   ：" + "#{(Time.now.to_f*1000).to_i}"
              #p "*"*10+" 校验位检查结束 " +"*"*10
            end
          end
          
        end

        #####################  判断访问时间  #####################
        def check_visit_restriction
          # #p "------判断访问时间------"
          st = Setting.allow_visit_start rescue '09:00'
          et = Setting.allow_visit_end rescue '18:00'
          # login_start = Time.parse(st)
          # login_end = Time.parse(et)
          time_now = Time.now
          # time_now.to_s(:time).between?(st, et)
          if !(time_now.to_s.between?(st, et))
            msg = "【规定时段】#{st}-#{et}外访问,被禁止!"
            render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
            gen_security_log(0,  @current_ip,  params[:action], 0, msg, "规定时段外访问")
            gen_audit_log(0,  @current_ip,  params[:action], 0, msg)
          end
        end

        #################  检验请求ip是否在设备（ip）黑名单  ################
        def check_blacklists
          blacklists = Blacklist.block_devise_ips
          # 未开启或者开启并且该ip在黑名单中允许访问
          if blacklists.include?(@current_ip)
            success = 0
            msg = "黑名单终端【#{@current_ip}】访问系统!"
            gen_security_log(0, @current_ip,  "请求访问", success, msg,  "系统黑名单")
            render :json => {code: 411, success: success, ip:  @current_ip, msg: msg }, :status => 200
          end
        end

        ################# 检验请求ip是否在设备（ip）白名单  ################
        def check_whitelists
          whitelists = Setting.whitelists
          # 未开启或者开启并且该ip在白名单中允许访问
          unless Setting.whitelists.size == 0 || (Setting.whitelists.size>0&&whitelists.include?(@current_ip))
            success = 0
            msg = "非白名单终端【#{@current_ip}】访问系统!"
            gen_security_log(0, @current_ip,  "请求访问", success, msg,  "系统白名单")
            render :json => {code: 401, success: success, ip:  @current_ip, msg: msg}, :status => 200
            # 记入安全事件日志 
          end
        end

        #####################  判断当前用户登录信息  #####################
        def set_current_user
          # @current_user  = User.find_by(token: params[:token]) rescue -1
          # p request.headers
          # # p request.headers["User-Agent"]
          # # p request.headers['"User-Agent"']
          # p request.headers['Authorization']&.start_with?("Bearer")
          # p request.headers['Authorization']
          # p jwt_token = request.headers['Authorization'].split(" ")&.last
          # p   jwt_info = User.decoded_jwt_infos(jwt_token) rescue nil
          # p "*"*100

          if request.headers['Authorization']&.start_with?("Bearer")
            jwt_token = request.headers['Authorization'].split(" ")&.last
            jwt_info = User.decoded_jwt_infos(jwt_token) rescue nil
            if jwt_info.present? && (Time.parse(jwt_info["time"]) + Setting.login_validity_period_hour.hours) > Time.now
              @current_user ||= User.actived.find_by_id(jwt_info["id"])
              
              # #p "@current_user"
              # p @current_user
              # 判断登录用户的IP，账户只允许在同一终端登录
              if @current_user && false && (@current_user.current_sign_in_ip !="" && @current_ip != @current_user.current_sign_in_ip && @current_user.current_sign_in_at + 5.minutes > Time.now)
                msg = "用户已在终端#{@current_user.current_sign_in_ip}登录，账户只5分钟内仅允许在一个终端登录！"
                login_other(msg)
                gen_login_log(@current_user.id, @current_ip,  "登录系统", 0, msg, "登录模块")
              # else
              #   msg = "正在使用非法Token访问系统，已被拒绝！"
              #   gen_security_log(0, @current_ip,  "请求访问", 0, msg, "系统")
              #   login_other(msg)
              end
            else
              login_other("当前登录已超时, 请重新登录系统！")
            end
          else
            Blacklist.gen_record(@current_ip)
            msg = "正在使用非法Token访问系统，已被拒绝！"
            gen_security_log(0, @current_ip,  "请求访问", 0, msg, "系统异常监测")
            login_other(msg)
          end
        end

        def success
          1
        end

        def page
          # params[:page].to_i || 1
          if params[:page].present?
            params[:page].to_i
          else
            1
          end
        end

        def per_page
          if params[:per_page].present?
            params[:per_page].to_i
          elsif params[:size].present?
            params[:size].to_i
          else
            20
          end
        end

        def t(name)
          res = I18n.t(name) rescue ''
          if res.include? "translation missing"
            case name = name.to_s
            when   name.include?(".formname") || name.include?(".modelname")
              res = name.split('.').first.titleize
            when name.include?(".")
              res = name.split('.').last.titleize
            else
              res = name.titleize
            end
          end
          res
        end

        #####################  请求状态码  #####################
        # - 200 请求成功
        def req_success(data, msg = "请求成功")
          render :json => {code: 200, success: 1, data: data, msg: msg }, :status => 200
        end

        # - 500 请求失败，此时需要弹出框显示接口返回的 msg 的字段内容
        def req_fail(msg = "请求失败")
          render :json => {code: 500, success: 0, ip:  @current_ip, msg: msg }, :status => 200
        end

        # - 401 账户在其他地方登陆等情况，此时需要强制跳转到登陆页面
        def login_other(msg ="该账户已在其他地方登陆！")
          render :json => {code: 401, success: 0, ip:  @current_ip, msg: msg  }, :status => 200
        end
        
        # - 411 当前账户或终端无法被禁止使用该系统
        def block_device
          render :json => {code: 411, success: 0, ip:  @current_ip, msg: "当前终端已被被禁止使用！" }, :status => 200
        end

        # - 421  页面丢失
        def lose_page
          render :json => {code: 421, success: 0, ip:  @current_ip, msg: "当前页面丢失" }, :status => 200
        end

        # - status   500 : 数据库连接失败, 此处需先校验  staus code 
        def lose_db
          render :json => {code: 500, success: 0, ip:  @current_ip, msg: "数据库连接失败" }, :status => 500
        end
        #####################  请求状态码  #####################
    end
  end
end
