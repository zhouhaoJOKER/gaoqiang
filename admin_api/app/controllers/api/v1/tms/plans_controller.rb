module Api
  module V1
    class Tms::PlansController < BaseController
      before_action :set_plans, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/plans
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Tms/plans列表")
        
        # 基础查询
        query = ::Tms::Plan.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Tms::Plan.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @plans = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @plans = @plans.where(parent_id: nil) if ::Tms::Plan.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @plans.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @plans.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @plans = @plans.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @plans.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/plans/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@plans) ? @plans.base_info : @plans.attributes 
        }
      end

      # POST /api/v1/plans
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Tms::Plan.column_names.include?("parent_id")
          plans_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @plans = ::Tms::Plan.new(plans_params)

        if @plans.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Tms::Plan.column_names.include?("parent_id") && params["parent_id"] != 0
            @plans.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Tms/plans#{@plans.name rescue @plans.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@plans) ? @plans.base_info : @plans.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Tms/plans失败: #{@plans.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @plans.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/plans/1
      def update
        if @plans.update(plans_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Tms::Plan.column_names.include?("parent_id")
            @plans.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@plans) ? @plans.base_info : @plans.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Tms/plans修改#{@plans.name rescue @plans.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Tms/plans修改#{@plans.name rescue @plans.id} 失败: #{@plans.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @plans.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/plans/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Tms/plans删除#{@plans.name rescue @plans.id}成功")
        @plans.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/plans_trees
      def plans_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Tms/plans树状列表")
        
        # 基础查询
        query = ::Tms::Plan.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Tms::Plan.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Tms::Plan.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @plans = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @plans.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @plans.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/plans/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Tms::Plan.respond_to?(:imp_exp_hander) ? ::Tms::Plan.imp_exp_hander : ::Tms::Plan.column_names
          i18n_column_names = ::Tms::Plan.respond_to?(:il8n_imp_exp_hander) ? ::Tms::Plan.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Tms/plans模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Tms::Plan.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Tms/plans预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/plans/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:plans].blank?

          ::Tms::Plan.transaction do
            params[:plans].each do |plans_params|
              plans = ::Tms::Plan.new(plans_params.to_unsafe_h)
              if plans.save
                plans.update_columns(parent_id: plans_params[:parent_id]) if plans_params[:parent_id].present? && ::Tms::Plan.column_names.include?("parent_id")
                results[:success] += 1
                data << plans
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Tms/plans#{plans.name rescue plans.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: plans_params, errors: plans.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Tms/plans#{plans_params[:name]}失败: #{plans.errors.full_messages.join(",")}")
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

          ::Tms::Plan.transaction do
            selected_ids.each do |plans_id|
              plans = ::Tms::Plan.find_by(id: plans_id)
              if plans
                if plans.update(update_params)
                  # 处理parent_id更新（如果需要）
                  plans.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Tms::Plan.column_names.include?("parent_id")
                  results[:success] += 1
                  data << plans
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Tms/plans#{plans.name rescue plans.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: plans_id, errors: plans.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Tms/plans#{plans.name rescue plans.id}失败: #{plans.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: plans_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Tms/plans失败: 记录ID #{plans_id} 不存在")
              end
            end
          end

        when "delete"
          ::Tms::Plan.transaction do
            params[:ids].each do |plans_id|
              plans = ::Tms::Plan.find(plans_id)
              if plans
                plans.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Tms/plans#{plans.name rescue plans.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: plans_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Tms/plans失败: 记录ID #{plans_id} 不存在")
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
        def set_plans
          @plans = ::Tms::Plan.find(params[:id]) rescue nil
          if @plans.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def plans_params
          params.permit(:contract_id, :code, :name, :date, :required_warehouse_entry_date, :client_id, :client_name, :contract_code, :product_id, :product_name, :qty, :specification, :outer_box_dimensions, :merchandiser_id, :pieces, :warehouse_address, :is_ready, :kind_id, :remark, :warehouse_entry_note, :volume_inspection, :gross_weight_inspection, :sort, :user_id, :updater_id, :py, :status, :ship_date, :shiper_id, :vehicle_usage, :direct_info)
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
            authorize!(params[:action].to_sym, @plans || ::Tms::Plan)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
