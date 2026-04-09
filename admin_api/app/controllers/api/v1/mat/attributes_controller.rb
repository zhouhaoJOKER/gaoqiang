module Api
  module V1
    class Mat::AttributesController < BaseController
      before_action :set_attribute, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/attributes
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/attribute列表")
        
        # 基础查询
        query = ::Mat::Attribute.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Attribute.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @attributes = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @attributes = @attributes.where(parent_id: nil) if ::Mat::Attribute.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @attributes.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @attributes.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @attributes = @attributes.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @attributes.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/attributes/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@attribute) ? @attribute.base_info : @attribute.attributes 
        }
      end

      # POST /api/v1/attributes
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mat::Attribute.column_names.include?("parent_id")
          attribute_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @attribute = ::Mat::Attribute.new(attribute_params)

        if @attribute.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Attribute.column_names.include?("parent_id") && params["parent_id"] != 0
            @attribute.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mat/attribute#{@attribute.name rescue @attribute.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@attribute) ? @attribute.base_info : @attribute.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mat/attribute失败: #{@attribute.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @attribute.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/attributes/1
      def update
        if @attribute.update(attribute_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Attribute.column_names.include?("parent_id")
            @attribute.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@attribute) ? @attribute.base_info : @attribute.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/attribute修改#{@attribute.name rescue @attribute.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mat/attribute修改#{@attribute.name rescue @attribute.id} 失败: #{@attribute.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @attribute.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/attributes/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/attribute删除#{@attribute.name rescue @attribute.id}成功")
        @attribute.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/attribute_trees
      def attribute_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/attribute树状列表")
        
        # 基础查询
        query = ::Mat::Attribute.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mat::Attribute.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Attribute.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @attributes = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @attributes.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @attributes.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/attributes/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mat::Attribute.respond_to?(:imp_exp_hander) ? ::Mat::Attribute.imp_exp_hander : ::Mat::Attribute.column_names
          i18n_column_names = ::Mat::Attribute.respond_to?(:il8n_imp_exp_hander) ? ::Mat::Attribute.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mat/attribute模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mat::Attribute.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mat/attribute预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/attributes/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:attributes].blank?

          ::Mat::Attribute.transaction do
            params[:attributes].each do |attribute_params|
              attribute = ::Mat::Attribute.new(attribute_params.to_unsafe_h)
              if attribute.save
                attribute.update_columns(parent_id: attribute_params[:parent_id]) if attribute_params[:parent_id].present? && ::Mat::Attribute.column_names.include?("parent_id")
                results[:success] += 1
                data << attribute
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mat/attribute#{attribute.name rescue attribute.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: attribute_params, errors: attribute.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mat/attribute#{attribute_params[:name]}失败: #{attribute.errors.full_messages.join(",")}")
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

          ::Mat::Attribute.transaction do
            selected_ids.each do |attribute_id|
              attribute = ::Mat::Attribute.find_by(id: attribute_id)
              if attribute
                if attribute.update(update_params)
                  # 处理parent_id更新（如果需要）
                  attribute.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mat::Attribute.column_names.include?("parent_id")
                  results[:success] += 1
                  data << attribute
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mat/attribute#{attribute.name rescue attribute.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: attribute_id, errors: attribute.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/attribute#{attribute.name rescue attribute.id}失败: #{attribute.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: attribute_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/attribute失败: 记录ID #{attribute_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mat::Attribute.transaction do
            params[:ids].each do |attribute_id|
              attribute = ::Mat::Attribute.find(attribute_id)
              if attribute
                attribute.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mat/attribute#{attribute.name rescue attribute.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: attribute_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mat/attribute失败: 记录ID #{attribute_id} 不存在")
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
        def set_attribute
          @attribute = ::Mat::Attribute.find(params[:id]) rescue nil
          if @attribute.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def attribute_params
          params.permit(:user_id, :updater_id, :company_id, :name, :py, :is_variant, :display_type, :sort)
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
            authorize!(params[:action].to_sym, @attribute || ::Mat::Attribute)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
