module Api
  module V1
    class Pm::StagesController < BaseController
      before_action :set_stage, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      

      # GET /api/v1/stages
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问任务列列表")

        # 基础查询
        query = ::Pm::Stage.order("sort desc")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Stage.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索功能
        @q = query.ransack(params[:q])
        @stages = @q.result()

        if params[:list]
          # 列表模式，只返回顶层数据
          @stages = @stages.where(parent_id: nil) if ::Pm::Stage.column_names.include?("parent_id")
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @stages.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @stages.size,
            size: per_page,
            page: page
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @stages = @stages.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @stages.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size,
            size: per_page_num,
            page: page_num
          }
        end
      end

      # GET /api/v1/stages/1
      def show
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: model_has_base_info?(@stage) ? @stage.base_info : @stage.attributes
        }
      end

      # POST /api/v1/stages
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Pm::Stage.column_names.include?("parent_id")
          stage_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end

        @stage = ::Pm::Stage.new(stage_params)
        @stage.user_id = current_user.id rescue ''

        if @stage.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::Stage.column_names.include?("parent_id") && params["parent_id"] != 0
            @stage.update_columns(parent_id: params["parent_id"])
          end
          if params["members"].present? && @stage.respond_to?(:members)
            params["members"].each do |user_id|
              member = ::Pm::Member.new(
                record_type: "::Pm::Stage",
                record_id: @stage.id,
                user_id: user_id,
                joined_at: Time.now,
              )
              if member.save
                gen_log(@current_user.id, @current_ip, "add_member", 1, "添加任务列成员#{member.user.name rescue member.user_id}成功")
              else
                gen_log(@current_user.id, @current_ip, "add_member", 0, "添加任务列成员#{member.user.name rescue member.user_id}失败: #{member.errors.full_messages.join(",")}")
              end
            end
          end
          

          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加任务列#{@stage.name rescue @stage.id}成功")
          render json: {
            code: 200,
            success: 1,
            msg: t("create_success"),
            data: model_has_base_info?(@stage) ? @stage.base_info : @stage.attributes
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加任务列失败: #{@stage.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @stage.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # PATCH/PUT /api/v1/stages/1
      def update
        update_params = stage_params.to_h
        update_params[:updater_id] = @current_user.id

        if @stage.update!(update_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::Stage.column_names.include?("parent_id")
            @stage.update_columns(parent_id: params["parent_id"])
          end
          
          # 处理任务列成员同步
          # members的结构为 [ {"id" => 26, "name" => "admin1"}, {"id" => 25, "name" => "admin"} ]
          # 逻辑：如果任务列成员存在记录不变，如果不存在则添加，如果传入列表中没有则删除
          if params["members"].present?
            # 获取传入的成员user_id列表（从id字段获取）
            incoming_user_ids = params["members"].map { |m| m[:id] || m["id"] }.compact.map(&:to_i)
            
            # 获取现有的所有成员
            existing_members = ::Pm::Member.where(
              record_type: "::Pm::Stage",
              record_id: @stage.id
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
                  record_type: "::Pm::Stage",
                  record_id: @stage.id,
                  user_id: user_id,
                  joined_at: Time.now
                )
                if member.save
                  gen_log(@current_user.id, @current_ip, "add_member", 1, "添加任务列成员#{member.user.name rescue user_id}成功")
                else
                  gen_log(@current_user.id, @current_ip, "add_member", 0, "添加任务列成员#{user_id}失败: #{member.errors.full_messages.join(",")}")
                end
              end
            end
            
            # 删除不在传入列表中的成员
            existing_members.to_a.each do |member|
              unless incoming_user_ids.include?(member.user_id)
                user_name = member.user.name rescue member.user_id
                member.destroy
                gen_log(@current_user.id, @current_ip, "remove_member", 1, "删除任务列成员#{user_name}成功")
              end
            end
          end

          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: model_has_base_info?(@stage) ? @stage.base_info : @stage.attributes
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "任务列修改#{@stage.name rescue @stage.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "任务列修改#{@stage.name rescue @stage.id} 失败: #{@stage.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @stage.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # DELETE /api/v1/stages/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "任务列删除#{@stage.name rescue @stage.id}成功")
        @stage.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/stage_trees
      def stage_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问任务列树状列表")

        # 基础查询
        query = ::Pm::Stage.order("code desc")

        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Pm::Stage.column_names.include?("parent_id")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Stage.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索和分页
        @q = query.ransack(params[:q])
        @stages = @q.result().paginate(page: params[:page], per_page: per_page)

        # 渲染结果
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @stages.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) },
          meta: {
            total: @stages.total_entries,
            per_page: per_page,
            page: page
          }
        }
      end

      # 导入功能
      # post api/v1/stages/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Pm::Stage.respond_to?(:imp_exp_hander) ? ::Pm::Stage.imp_exp_hander : ::Pm::Stage.column_names
          i18n_column_names = ::Pm::Stage.respond_to?(:il8n_imp_exp_hander) ? ::Pm::Stage.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入任务列模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Pm::Stage.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入任务列预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/stages/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:stages].blank?

          ::Pm::Stage.transaction do
            params[:stages].each do |stage_params|
              stage = ::Pm::Stage.new(stage_params.to_unsafe_h)
              if stage.save
                stage.update_columns(parent_id: stage_params[:parent_id]) if stage_params[:parent_id].present? && ::Pm::Stage.column_names.include?("parent_id")
                results[:success] += 1
                data << stage
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增任务列#{stage.name rescue stage.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: stage_params, errors: stage.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增任务列#{stage_params[:name]}失败: #{stage.errors.full_messages.join(",")}")
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

          ::Pm::Stage.transaction do
            selected_ids.each do |stage_id|
              stage = ::Pm::Stage.find_by(id: stage_id)
              if stage
                if stage.update(update_params)
                  # 处理parent_id更新（如果需要）
                  stage.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Pm::Stage.column_names.include?("parent_id")
                  results[:success] += 1
                  data << stage
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改任务列#{stage.name rescue stage.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: stage_id, errors: stage.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改任务列#{stage.name rescue stage.id}失败: #{stage.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: stage_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改任务列失败: 记录ID #{stage_id} 不存在")
              end
            end
          end

        when "delete"
          ::Pm::Stage.transaction do
            params[:ids].each do |stage_id|
              stage = ::Pm::Stage.find(stage_id)
              if stage
                stage.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除任务列#{stage.name rescue stage.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: stage_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除任务列失败: 记录ID #{stage_id} 不存在")
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
        def set_stage
          @stage = ::Pm::Stage.find(params[:id]) rescue nil
          if @stage.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def stage_params
          params.permit(:portfolio_id,  :parent_id,  :code,  :name,  :py,  :pinyin,  :logo,  :status_id,  :source_id,  :start_date,  :end_date,  :is_star,  :manager_id,  :description,  :degree,  :labels,  :custom_fields,  :user_id,  :updater_id,  :company_id,  :is_public,  :is_archived,  :is_suspended,  :suspend_at,  :suspender_id)
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
            authorize!(params[:action].to_sym, @stage || ::Pm::Stage)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
