module Api
  module V1
    class Tms::OrdersController < BaseController
      before_action :set_orders, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/orders
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Tms/orders列表")
        
        # 基础查询
        query = ::Tms::Order.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Tms::Order.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @orders = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @orders = @orders.where(parent_id: nil) if ::Tms::Order.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @orders.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @orders = @orders.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/orders/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@orders) ? @orders.base_info : @orders.attributes 
        }
      end

      # POST /api/v1/orders
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Tms::Order.column_names.include?("parent_id")
          orders_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @orders = ::Tms::Order.new(orders_params)

        if @orders.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Tms::Order.column_names.include?("parent_id") && params["parent_id"] != 0
            @orders.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Tms/orders#{@orders.name rescue @orders.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@orders) ? @orders.base_info : @orders.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Tms/orders失败: #{@orders.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @orders.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/orders/1
      def update
        if @orders.update(orders_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Tms::Order.column_names.include?("parent_id")
            @orders.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@orders) ? @orders.base_info : @orders.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Tms/orders修改#{@orders.name rescue @orders.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Tms/orders修改#{@orders.name rescue @orders.id} 失败: #{@orders.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @orders.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/orders/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Tms/orders删除#{@orders.name rescue @orders.id}成功")
        @orders.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/orders_trees
      def orders_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Tms/orders树状列表")
        
        # 基础查询
        query = ::Tms::Order.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Tms::Order.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Tms::Order.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @orders = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @orders.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @orders.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/orders/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Tms::Order.respond_to?(:imp_exp_hander) ? ::Tms::Order.imp_exp_hander : ::Tms::Order.column_names
          i18n_column_names = ::Tms::Order.respond_to?(:il8n_imp_exp_hander) ? ::Tms::Order.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Tms/orders模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Tms::Order.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Tms/orders预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/orders/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:orders].blank?

          ::Tms::Order.transaction do
            params[:orders].each do |orders_params|
              orders = ::Tms::Order.new(orders_params.to_unsafe_h)
              if orders.save
                orders.update_columns(parent_id: orders_params[:parent_id]) if orders_params[:parent_id].present? && ::Tms::Order.column_names.include?("parent_id")
                results[:success] += 1
                data << orders
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Tms/orders#{orders.name rescue orders.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: orders_params, errors: orders.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Tms/orders#{orders_params[:name]}失败: #{orders.errors.full_messages.join(",")}")
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

          ::Tms::Order.transaction do
            selected_ids.each do |orders_id|
              orders = ::Tms::Order.find_by(id: orders_id)
              if orders
                if orders.update(update_params)
                  # 处理parent_id更新（如果需要）
                  orders.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Tms::Order.column_names.include?("parent_id")
                  results[:success] += 1
                  data << orders
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Tms/orders#{orders.name rescue orders.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: orders_id, errors: orders.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Tms/orders#{orders.name rescue orders.id}失败: #{orders.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: orders_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Tms/orders失败: 记录ID #{orders_id} 不存在")
              end
            end
          end

        when "delete"
          ::Tms::Order.transaction do
            params[:ids].each do |orders_id|
              orders = ::Tms::Order.find(orders_id)
              if orders
                orders.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Tms/orders#{orders.name rescue orders.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: orders_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Tms/orders失败: 记录ID #{orders_id} 不存在")
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
        def set_orders
          @orders = ::Tms::Order.find(params[:id]) rescue nil
          if @orders.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def orders_params
          params.permit(:contract_id, :document_number, :document_date, :company_name, :reference_code, :consignee_name, :consignee_contact, :consignee_phone, :delivery_address, :carrier_id_no, :vehicle_no, :carrier_name, :consignee_stamp_note, :consignee_signature_note, :approved_id, :prepared_id, :contract_note, :user_id, :updater_id, :py)
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
            authorize!(params[:action].to_sym, @orders || ::Tms::Order)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
