module Api
  module V1
    class Pm::TimesheetsController < BaseController
      before_action :set_timesheet, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      

      # GET /api/v1/timesheets
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问添加工时列表")

        # 基础查询
        query = ::Pm::Timesheet.order("id desc")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Timesheet.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索功能
        @q = query.ransack(params[:q])
        @timesheets = @q.result()

        if params[:list]
          # 列表模式，只返回顶层数据
          @timesheets = @timesheets.where(parent_id: nil) if ::Pm::Timesheet.column_names.include?("parent_id")
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @timesheets.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @timesheets.size,
            size: per_page,
            page: page
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @timesheets = @timesheets.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @timesheets.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size,
            size: per_page_num,
            page: page_num
          }
        end
      end

      # GET /api/v1/timesheets/1
      def show
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: model_has_base_info?(@timesheet) ? @timesheet.base_info : @timesheet.attributes
        }
      end

      # POST /api/v1/timesheets
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Pm::Timesheet.column_names.include?("parent_id")
          timesheet_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        if  params[:timesheets].present?
          params[:timesheets].each do |single|
            timesheet_data = single.permit(:kind, :project_id, :task_id, :date, :time, :user_id, :description).to_h
            @timesheet = ::Pm::Timesheet.new(timesheet_data)
            @timesheet.updater_id = @current_user.id rescue ''
            @timesheet.save

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加添加工时#{@timesheet.time rescue @timesheet.id}成功")
          end

          render json: {
            code: 200,
            success: 1,
            msg: t("create_success"),
            data: ''
          }
        else

          @timesheet = ::Pm::Timesheet.new(timesheet_params)
          # @timesheet.user_id = current_user.id rescue ''

          if @timesheet.save

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加添加工时#{@timesheet.name rescue @timesheet.id}成功")
            render json: {
              code: 200,
              success: 1,
              msg: t("create_success"),
              data: model_has_base_info?(@timesheet) ? @timesheet.base_info : @timesheet.attributes
            }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加添加工时失败: #{@timesheet.errors.full_messages.join(",")}")
            render json: {
              code: 500,
              success: 0,
              msg: @timesheet.errors.full_messages.join(","),
              data: ""
            }
          end
        end
        
      end

      # PATCH/PUT /api/v1/timesheets/1
      def update
        update_params = timesheet_params.to_h
        update_params[:updater_id] = @current_user.id
        
        if @timesheet.update!(update_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::Timesheet.column_names.include?("parent_id")
            @timesheet.update_columns(parent_id: params["parent_id"])
          end
          
          # 处理项目成员同步
          # members的结构为 [ {"id" => 26, "name" => "admin1"}, {"id" => 25, "name" => "admin"} ]
          # 逻辑：如果项目成员存在记录不变，如果不存在则添加，如果传入列表中没有则删除
          if params["members"].present?
            # 获取传入的成员user_id列表（从id字段获取）
            incoming_user_ids = params["members"].map { |m| m[:id] || m["id"] }.compact.map(&:to_i)
            
            # 获取现有的所有成员
            existing_members = ::Pm::Member.where(
              record_type: "::Pm::Timesheet",
              record_id: @timesheet.id
            )
            
            # 处理传入的成员：添加或更新
            params["members"].each do |member_params|
              # 从id字段获取user_id（兼容symbol和string格式）
              raw_id = member_params[:id] || member_params["id"]
              next if raw_id.blank?
              
              user_id = raw_id.to_i
              next if user_id == 0
              
              member = existing_members.find_by(user_id: user_id)
              
              if member
                # 成员已存在，记录不变（可以在这里添加其他更新逻辑）
                # 如果需要更新joined_at，可以取消下面的注释
                # member.update_columns(joined_at: Time.now)
              else
                # 成员不存在，创建新成员
                member = ::Pm::Member.new(
                  record_type: "::Pm::Timesheet",
                  record_id: @timesheet.id,
                  user_id: user_id,
                  joined_at: Time.now
                )
                if member.save
                  gen_log(@current_user.id, @current_ip, "add_member", 1, "添加项目成员#{member.user.name rescue user_id}成功")
                else
                  gen_log(@current_user.id, @current_ip, "add_member", 0, "添加项目成员#{user_id}失败: #{member.errors.full_messages.join(",")}")
                end
              end
            end
            
            # 删除不在传入列表中的成员
            existing_members.to_a.each do |member|
              unless incoming_user_ids.include?(member.user_id)
                user_name = member.user.name rescue member.user_id
                member.destroy
                gen_log(@current_user.id, @current_ip, "remove_member", 1, "删除项目成员#{user_name}成功")
              end
            end
          end

          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: model_has_base_info?(@timesheet) ? @timesheet.base_info : @timesheet.attributes
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加工时修改#{@timesheet.name rescue @timesheet.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加工时修改#{@timesheet.name rescue @timesheet.id} 失败: #{@timesheet.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @timesheet.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # DELETE /api/v1/timesheets/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "添加工时删除#{@timesheet.name rescue @timesheet.id}成功")
        @timesheet.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/timesheet_trees
      def timesheet_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问添加工时树状列表")

        # 基础查询
        query = ::Pm::Timesheet.order("code desc")

        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Pm::Timesheet.column_names.include?("parent_id")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Timesheet.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索和分页
        @q = query.ransack(params[:q])
        @timesheets = @q.result().paginate(page: params[:page], per_page: per_page)

        # 渲染结果
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @timesheets.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) },
          meta: {
            total: @timesheets.total_entries,
            per_page: per_page,
            page: page
          }
        }
      end

      # 导入功能
      # post api/v1/timesheets/import
      def import
        if params[:tag] == "import_timesheet"
          column_names = ::Pm::Timesheet.respond_to?(:imp_exp_hander) ? ::Pm::Timesheet.imp_exp_hander : ::Pm::Timesheet.column_names
          i18n_column_names = ::Pm::Timesheet.respond_to?(:il8n_imp_exp_hander) ? ::Pm::Timesheet.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_timesheet", 1, "下载导入添加工时添加工时成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Pm::Timesheet.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入添加工时预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/timesheets/batch_action
      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?

        action = params[:actions]
        valid_actions = [ "create", "update", "delete" ]
        return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
        data = []
        results = {
          success: 0,
          failed: 0,
          errors: []
        }
        case action
        when "create"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:timesheets].blank?

          ::Pm::Timesheet.transaction do
            params[:timesheets].each do |timesheet_params|
              timesheet = ::Pm::Timesheet.new(timesheet_params.to_unsafe_h)
              if timesheet.save
                timesheet.update_columns(parent_id: timesheet_params[:parent_id]) if timesheet_params[:parent_id].present? && ::Pm::Timesheet.column_names.include?("parent_id")
                results[:success] += 1
                data << timesheet
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增添加工时#{timesheet.name rescue timesheet.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: timesheet_params, errors: timesheet.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增添加工时#{timesheet_params[:name]}失败: #{timesheet.errors.full_messages.join(",")}")
              end
            end
          end

        when "update"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?

          selected_ids = params[:ids]
          fields = params[:fields]
          values = params[:values]

          # 过滤出需要更新的字段和值
          update_params = {}
          fields.each do |field|
            update_params[field.to_sym] = values[field] if values.key?(field)
          end

          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?

          ::Pm::Timesheet.transaction do
            selected_ids.each do |timesheet_id|
              timesheet = ::Pm::Timesheet.find_by(id: timesheet_id)
              if timesheet
                if timesheet.update(update_params)
                  # 处理parent_id更新（如果需要）
                  timesheet.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Pm::Timesheet.column_names.include?("parent_id")
                  results[:success] += 1
                  data << timesheet
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改添加工时#{timesheet.name rescue timesheet.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: timesheet_id, errors: timesheet.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改添加工时#{timesheet.name rescue timesheet.id}失败: #{timesheet.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: timesheet_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改添加工时失败: 记录ID #{timesheet_id} 不存在")
              end
            end
          end

        when "delete"
          ::Pm::Timesheet.transaction do
            params[:ids].each do |timesheet_id|
              timesheet = ::Pm::Timesheet.find(timesheet_id)
              if timesheet
                timesheet.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除添加工时#{timesheet.name rescue timesheet.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: timesheet_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除添加工时失败: 记录ID #{timesheet_id} 不存在")
              end
            end
          end
        end

        render json: {
          code: 200,
          success: 1,
          msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条",
          data: data,
          results: results
        }
      end

      private
        def set_timesheet
          @timesheet = ::Pm::Timesheet.find(params[:id]) rescue nil
          if @timesheet.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def timesheet_params
          params.permit(:kind, :project_id, :task_id, :date, :time, :user_id, :updater_id, :description)
        end

        # 辅助方法：检查模型是否有base_info方法
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end

        # 辅助方法：检查模型是否有tree_info方法
        def model_has_tree_info?(model)
          model.respond_to?(:tree_info)
        end

        # 权限校验方法
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @timesheet || ::Pm::Timesheet)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
