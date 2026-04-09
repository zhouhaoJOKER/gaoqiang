module Api
  module V1
    class Mfg::OprateLinesController < BaseController
      before_action :set_oprate_lines, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/oprate_lines
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/oprate lines列表")
        
        # 基础查询
        query = ::Mfg::OprateLine.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mfg::OprateLine.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @oprate_lines = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @oprate_lines = @oprate_lines.where(parent_id: nil) if ::Mfg::OprateLine.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @oprate_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @oprate_lines.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @oprate_lines = @oprate_lines.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @oprate_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/oprate_lines/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@oprate_lines) ? @oprate_lines.base_info : @oprate_lines.attributes 
        }
      end

      # POST /api/v1/oprate_lines
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mfg::OprateLine.column_names.include?("parent_id")
          oprate_lines_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @oprate_lines = ::Mfg::OprateLine.new(oprate_lines_params)

        if @oprate_lines.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mfg::OprateLine.column_names.include?("parent_id") && params["parent_id"] != 0
            @oprate_lines.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/oprate lines#{@oprate_lines.name rescue @oprate_lines.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@oprate_lines) ? @oprate_lines.base_info : @oprate_lines.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/oprate lines失败: #{@oprate_lines.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @oprate_lines.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/oprate_lines/1
      def update
        if @oprate_lines.update(oprate_lines_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mfg::OprateLine.column_names.include?("parent_id")
            @oprate_lines.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@oprate_lines) ? @oprate_lines.base_info : @oprate_lines.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/oprate lines修改#{@oprate_lines.name rescue @oprate_lines.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/oprate lines修改#{@oprate_lines.name rescue @oprate_lines.id} 失败: #{@oprate_lines.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @oprate_lines.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/oprate_lines/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/oprate lines删除#{@oprate_lines.name rescue @oprate_lines.id}成功")
        @oprate_lines.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/oprate_lines_trees
      def oprate_lines_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/oprate lines树状列表")
        
        # 基础查询
        query = ::Mfg::OprateLine.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mfg::OprateLine.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mfg::OprateLine.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @oprate_lines = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @oprate_lines.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @oprate_lines.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/oprate_lines/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::OprateLine.respond_to?(:imp_exp_hander) ? ::Mfg::OprateLine.imp_exp_hander : ::Mfg::OprateLine.column_names
          i18n_column_names = ::Mfg::OprateLine.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::OprateLine.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/oprate lines模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mfg::OprateLine.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/oprate lines预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/oprate_lines/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:oprate_lines].blank?

          ::Mfg::OprateLine.transaction do
            params[:oprate_lines].each do |oprate_lines_params|
              oprate_lines = ::Mfg::OprateLine.new(oprate_lines_params.to_unsafe_h)
              if oprate_lines.save
                oprate_lines.update_columns(parent_id: oprate_lines_params[:parent_id]) if oprate_lines_params[:parent_id].present? && ::Mfg::OprateLine.column_names.include?("parent_id")
                results[:success] += 1
                data << oprate_lines
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/oprate lines#{oprate_lines.name rescue oprate_lines.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: oprate_lines_params, errors: oprate_lines.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/oprate lines#{oprate_lines_params[:name]}失败: #{oprate_lines.errors.full_messages.join(",")}")
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

          ::Mfg::OprateLine.transaction do
            selected_ids.each do |oprate_lines_id|
              oprate_lines = ::Mfg::OprateLine.find_by(id: oprate_lines_id)
              if oprate_lines
                if oprate_lines.update(update_params)
                  # 处理parent_id更新（如果需要）
                  oprate_lines.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mfg::OprateLine.column_names.include?("parent_id")
                  results[:success] += 1
                  data << oprate_lines
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/oprate lines#{oprate_lines.name rescue oprate_lines.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: oprate_lines_id, errors: oprate_lines.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/oprate lines#{oprate_lines.name rescue oprate_lines.id}失败: #{oprate_lines.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: oprate_lines_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/oprate lines失败: 记录ID #{oprate_lines_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mfg::OprateLine.transaction do
            params[:ids].each do |oprate_lines_id|
              oprate_lines = ::Mfg::OprateLine.find(oprate_lines_id)
              if oprate_lines
                oprate_lines.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/oprate lines#{oprate_lines.name rescue oprate_lines.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: oprate_lines_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/oprate lines失败: 记录ID #{oprate_lines_id} 不存在")
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
        def set_oprate_lines
          @oprate_lines = ::Mfg::OprateLine.find(params[:id]) rescue nil
          if @oprate_lines.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def oprate_lines_params
          params.permit(:operate_id, :sort, :name, :batch_number, :qty_kg, :user_id)
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
            authorize!(params[:action].to_sym, @oprate_lines || ::Mfg::OprateLine)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
