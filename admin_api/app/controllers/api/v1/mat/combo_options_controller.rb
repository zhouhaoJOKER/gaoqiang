module Api
  module V1
    class Mat::ComboOptionsController < BaseController
      before_action :set_combo_option, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/combo_options
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/combo option列表")
        
        # 基础查询
        query = ::Mat::ComboOption.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::ComboOption.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @combo_options = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @combo_options = @combo_options.where(parent_id: nil) if ::Mat::ComboOption.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @combo_options.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @combo_options.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @combo_options = @combo_options.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @combo_options.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/combo_options/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@combo_option) ? @combo_option.base_info : @combo_option.attributes 
        }
      end

      # POST /api/v1/combo_options
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mat::ComboOption.column_names.include?("parent_id")
          combo_option_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @combo_option = ::Mat::ComboOption.new(combo_option_params)

        if @combo_option.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::ComboOption.column_names.include?("parent_id") && params["parent_id"] != 0
            @combo_option.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mat/combo option#{@combo_option.name rescue @combo_option.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@combo_option) ? @combo_option.base_info : @combo_option.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mat/combo option失败: #{@combo_option.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @combo_option.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/combo_options/1
      def update
        combo_option_params = combo_option_params.to_h
        if @combo_option.update(combo_option_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::ComboOption.column_names.include?("parent_id")
            @combo_option.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@combo_option) ? @combo_option.base_info : @combo_option.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/combo option修改#{@combo_option.name rescue @combo_option.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mat/combo option修改#{@combo_option.name rescue @combo_option.id} 失败: #{@combo_option.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @combo_option.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/combo_options/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/combo option删除#{@combo_option.name rescue @combo_option.id}成功")
        @combo_option.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/combo_option_trees
      def combo_option_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/combo option树状列表")
        
        # 基础查询
        query = ::Mat::ComboOption.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mat::ComboOption.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::ComboOption.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @combo_options = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @combo_options.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @combo_options.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/combo_options/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mat::ComboOption.respond_to?(:imp_exp_hander) ? ::Mat::ComboOption.imp_exp_hander : ::Mat::ComboOption.column_names
          i18n_column_names = ::Mat::ComboOption.respond_to?(:il8n_imp_exp_hander) ? ::Mat::ComboOption.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mat/combo option模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mat::ComboOption.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mat/combo option预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/combo_options/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:combo_options].blank?

          ::Mat::ComboOption.transaction do
            params[:combo_options].each do |combo_option_params|
              combo_option = ::Mat::ComboOption.new(combo_option_params.to_unsafe_h)
              if combo_option.save
                combo_option.update_columns(parent_id: combo_option_params[:parent_id]) if combo_option_params[:parent_id].present? && ::Mat::ComboOption.column_names.include?("parent_id")
                results[:success] += 1
                data << combo_option
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mat/combo option#{combo_option.name rescue combo_option.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: combo_option_params, errors: combo_option.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mat/combo option#{combo_option_params[:name]}失败: #{combo_option.errors.full_messages.join(",")}")
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

          ::Mat::ComboOption.transaction do
            selected_ids.each do |combo_option_id|
              combo_option = ::Mat::ComboOption.find_by(id: combo_option_id)
              if combo_option
                if combo_option.update(update_params)
                  # 处理parent_id更新（如果需要）
                  combo_option.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mat::ComboOption.column_names.include?("parent_id")
                  results[:success] += 1
                  data << combo_option
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mat/combo option#{combo_option.name rescue combo_option.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: combo_option_id, errors: combo_option.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/combo option#{combo_option.name rescue combo_option.id}失败: #{combo_option.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: combo_option_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/combo option失败: 记录ID #{combo_option_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mat::ComboOption.transaction do
            params[:ids].each do |combo_option_id|
              combo_option = ::Mat::ComboOption.find(combo_option_id)
              if combo_option
                combo_option.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mat/combo option#{combo_option.name rescue combo_option.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: combo_option_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mat/combo option失败: 记录ID #{combo_option_id} 不存在")
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
        def set_combo_option
          @combo_option = ::Mat::ComboOption.find(params[:id]) rescue nil
          if @combo_option.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def combo_option_params
          params.permit(:combo_id, :product_id, :name, :price, :extra_price)
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
            authorize!(params[:action].to_sym, @combo_option || ::Mat::ComboOption)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
