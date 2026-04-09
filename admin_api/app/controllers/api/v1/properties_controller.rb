module Api
  module V1
    class PropertiesController < BaseController
      before_action :set_property, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/properties
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Property列表")
        
        # 基础查询
        query = Property.order("sort desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| Property.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @properties = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @properties = @properties.where(parent_id: nil) if Property.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @properties.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @properties.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @properties = @properties.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @properties.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/properties/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@property) ? @property.base_info : @property.attributes 
        }
      end

      # POST /api/v1/properties
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && Property.column_names.include?("parent_id")
          property_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @property = Property.new(property_params)

        if @property.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && Property.column_names.include?("parent_id") && params["parent_id"] != 0
            @property.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Property#{@property.name rescue @property.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@property) ? @property.base_info : @property.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Property失败: #{@property.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @property.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/properties/1
      def update
        if @property.update(property_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && Property.column_names.include?("parent_id")
            @property.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@property) ? @property.base_info : @property.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Property修改#{@property.name rescue @property.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Property修改#{@property.name rescue @property.id} 失败: #{@property.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @property.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/properties/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Property删除#{@property.name rescue @property.id}成功")
        @property.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/property_trees
      def property_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Property树状列表")
        
        # 基础查询
        query = Property.order("code desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if Property.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| Property.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @properties = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @properties.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @properties.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/properties/import
      def import
        if params[:tag] == "import_template"
          column_names = Property.respond_to?(:imp_exp_hander) ? Property.imp_exp_hander : Property.column_names
          i18n_column_names = Property.respond_to?(:il8n_imp_exp_hander) ? Property.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Property模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入Property.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Property预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/properties/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:properties].blank?

          Property.transaction do
            params[:properties].each do |property_params|
              property = Property.new(property_params.to_unsafe_h)
              if property.save
                property.update_columns(parent_id: property_params[:parent_id]) if property_params[:parent_id].present? && Property.column_names.include?("parent_id")
                results[:success] += 1
                data << property
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Property#{property.name rescue property.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: property_params, errors: property.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Property#{property_params[:name]}失败: #{property.errors.full_messages.join(",")}")
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

          Property.transaction do
            selected_ids.each do |property_id|
              property = Property.find_by(id: property_id)
              if property
                if property.update(update_params)
                  # 处理parent_id更新（如果需要）
                  property.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && Property.column_names.include?("parent_id")
                  results[:success] += 1
                  data << property
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Property#{property.name rescue property.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: property_id, errors: property.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Property#{property.name rescue property.id}失败: #{property.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: property_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Property失败: 记录ID #{property_id} 不存在")
              end
            end
          end

        when "delete"
          Property.transaction do
            params[:ids].each do |property_id|
              property = Property.find(property_id)
              if property
                property.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Property#{property.name rescue property.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: property_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Property失败: 记录ID #{property_id} 不存在")
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
        def set_property
          @property = Property.find(params[:id]) rescue nil
          if @property.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def property_params
          params.permit(:sign, :name, :parent_id, :py, :sort, :is_open, :color, :user_id, :abbr)
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
            authorize!(params[:action].to_sym, @property || Property)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
