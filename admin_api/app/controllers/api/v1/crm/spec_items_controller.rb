module Api
  module V1
    class Crm::SpecItemsController < BaseController
      before_action :set_spec_items, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/spec_items
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Crm/spec items列表")
        
        # 基础查询
        query = ::Crm::SpecItem.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Crm::SpecItem.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @spec_items = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @spec_items = @spec_items.where(parent_id: nil) if ::Crm::SpecItem.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @spec_items.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @spec_items.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @spec_items = @spec_items.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @spec_items.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/spec_items/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@spec_items) ? @spec_items.base_info : @spec_items.attributes 
        }
      end

      # POST /api/v1/spec_items
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Crm::SpecItem.column_names.include?("parent_id")
          spec_items_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @spec_items = ::Crm::SpecItem.new(spec_items_params)

        if @spec_items.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Crm::SpecItem.column_names.include?("parent_id") && params["parent_id"] != 0
            @spec_items.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Crm/spec items#{@spec_items.name rescue @spec_items.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@spec_items) ? @spec_items.base_info : @spec_items.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Crm/spec items失败: #{@spec_items.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @spec_items.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/spec_items/1
      def update
        update_params = spec_items_params.to_h
        # 若传入 values，将不在现有 values 中的项追加进去
        if params[:values].present?
          incoming = parse_values_param(params[:values])
          current = Array(@spec_items.values)
          update_params[:values] = current + (incoming - current)
        end

        if @spec_items.update(update_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Crm::SpecItem.column_names.include?("parent_id")
            @spec_items.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@spec_items) ? @spec_items.base_info : @spec_items.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Crm/spec items修改#{@spec_items.name rescue @spec_items.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Crm/spec items修改#{@spec_items.name rescue @spec_items.id} 失败: #{@spec_items.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @spec_items.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/spec_items/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Crm/spec items删除#{@spec_items.name rescue @spec_items.id}成功")
        @spec_items.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/spec_items_trees
      def spec_items_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Crm/spec items树状列表")
        
        # 基础查询
        query = ::Crm::SpecItem.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Crm::SpecItem.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Crm::SpecItem.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @spec_items = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @spec_items.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @spec_items.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/spec_items/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Crm::SpecItem.respond_to?(:imp_exp_hander) ? ::Crm::SpecItem.imp_exp_hander : ::Crm::SpecItem.column_names
          i18n_column_names = ::Crm::SpecItem.respond_to?(:il8n_imp_exp_hander) ? ::Crm::SpecItem.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Crm/spec items模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Crm::SpecItem.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Crm/spec items预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/spec_items/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:spec_items].blank?

          ::Crm::SpecItem.transaction do
            params[:spec_items].each do |spec_items_params|
              spec_items = ::Crm::SpecItem.new(spec_items_params.to_unsafe_h)
              if spec_items.save
                spec_items.update_columns(parent_id: spec_items_params[:parent_id]) if spec_items_params[:parent_id].present? && ::Crm::SpecItem.column_names.include?("parent_id")
                results[:success] += 1
                data << spec_items
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Crm/spec items#{spec_items.name rescue spec_items.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: spec_items_params, errors: spec_items.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Crm/spec items#{spec_items_params[:name]}失败: #{spec_items.errors.full_messages.join(",")}")
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

          ::Crm::SpecItem.transaction do
            selected_ids.each do |spec_items_id|
              spec_items = ::Crm::SpecItem.find_by(id: spec_items_id)
              if spec_items
                if spec_items.update(update_params)
                  # 处理parent_id更新（如果需要）
                  spec_items.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Crm::SpecItem.column_names.include?("parent_id")
                  results[:success] += 1
                  data << spec_items
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Crm/spec items#{spec_items.name rescue spec_items.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: spec_items_id, errors: spec_items.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Crm/spec items#{spec_items.name rescue spec_items.id}失败: #{spec_items.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: spec_items_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Crm/spec items失败: 记录ID #{spec_items_id} 不存在")
              end
            end
          end

        when "delete"
          ::Crm::SpecItem.transaction do
            params[:ids].each do |spec_items_id|
              spec_items = ::Crm::SpecItem.find(spec_items_id)
              if spec_items
                spec_items.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Crm/spec items#{spec_items.name rescue spec_items.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: spec_items_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Crm/spec items失败: 记录ID #{spec_items_id} 不存在")
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
        def set_spec_items
          @spec_items = ::Crm::SpecItem.find(params[:id]) rescue nil
          if @spec_items.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def spec_items_params
          params.permit(:code, :name, :name_en, :values, :sort, :remark, :user_id, :updater_id, :py)
        end

        # 解析 values 参数（支持 JSON 字符串或数组）
        def parse_values_param(v)
          case v
          when String
            JSON.parse(v)
          when Array
            v
          else
            []
          end
        rescue JSON::ParserError
          []
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
            authorize!(params[:action].to_sym, @spec_items || ::Crm::SpecItem)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
