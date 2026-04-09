module Api
  module V1
    class Crm::HandoversController < BaseController
      before_action :set_handovers, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/handovers
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Crm/handovers列表")
        
        # 基础查询
        query = ::Crm::Handover.order("id desc").includes(:handover_lines)
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Crm::Handover.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @handovers = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @handovers = @handovers.where(parent_id: nil) if ::Crm::Handover.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @handovers.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @handovers.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @handovers = @handovers.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @handovers.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/handovers/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@handovers) ? @handovers.base_info : @handovers.attributes 
        }
      end

      # POST /api/v1/handovers
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Crm::Handover.column_names.include?("parent_id")
          handovers_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @handovers = ::Crm::Handover.new(handovers_params)

        if @handovers.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Crm::Handover.column_names.include?("parent_id") && params["parent_id"] != 0
            @handovers.update_columns(parent_id: params["parent_id"])
          end

          # 同步创建交接明细
          create_handover_lines if handover_lines_params.present?
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Crm/handovers#{@handovers.name rescue @handovers.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@handovers) ? @handovers.base_info : @handovers.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Crm/handovers失败: #{@handovers.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @handovers.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/handovers/1
      def update
        if @handovers.update(handovers_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Crm::Handover.column_names.include?("parent_id")
            @handovers.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@handovers) ? @handovers.base_info : @handovers.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Crm/handovers修改#{@handovers.name rescue @handovers.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Crm/handovers修改#{@handovers.name rescue @handovers.id} 失败: #{@handovers.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @handovers.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/handovers/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Crm/handovers删除#{@handovers.name rescue @handovers.id}成功")
        @handovers.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/handovers_trees
      def handovers_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Crm/handovers树状列表")
        
        # 基础查询
        query = ::Crm::Handover.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Crm::Handover.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Crm::Handover.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @handovers = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @handovers.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @handovers.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/handovers/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Crm::Handover.respond_to?(:imp_exp_hander) ? ::Crm::Handover.imp_exp_hander : ::Crm::Handover.column_names
          i18n_column_names = ::Crm::Handover.respond_to?(:il8n_imp_exp_hander) ? ::Crm::Handover.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Crm/handovers模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Crm::Handover.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Crm/handovers预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/handovers/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:handovers].blank?

          ::Crm::Handover.transaction do
            params[:handovers].each do |handovers_params|
              handovers = ::Crm::Handover.new(handovers_params.to_unsafe_h)
              if handovers.save
                handovers.update_columns(parent_id: handovers_params[:parent_id]) if handovers_params[:parent_id].present? && ::Crm::Handover.column_names.include?("parent_id")
                results[:success] += 1
                data << handovers
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Crm/handovers#{handovers.name rescue handovers.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: handovers_params, errors: handovers.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Crm/handovers#{handovers_params[:name]}失败: #{handovers.errors.full_messages.join(",")}")
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

          ::Crm::Handover.transaction do
            selected_ids.each do |handovers_id|
              handovers = ::Crm::Handover.find_by(id: handovers_id)
              if handovers
                if handovers.update(update_params)
                  # 处理parent_id更新（如果需要）
                  handovers.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Crm::Handover.column_names.include?("parent_id")
                  results[:success] += 1
                  data << handovers
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Crm/handovers#{handovers.name rescue handovers.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: handovers_id, errors: handovers.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Crm/handovers#{handovers.name rescue handovers.id}失败: #{handovers.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: handovers_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Crm/handovers失败: 记录ID #{handovers_id} 不存在")
              end
            end
          end

        when "delete"
          ::Crm::Handover.transaction do
            params[:ids].each do |handovers_id|
              handovers = ::Crm::Handover.find(handovers_id)
              if handovers
                handovers.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Crm/handovers#{handovers.name rescue handovers.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: handovers_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Crm/handovers失败: 记录ID #{handovers_id} 不存在")
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
        def set_handovers
          @handovers = ::Crm::Handover.find(params[:id]) rescue nil
          if @handovers.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def handovers_params
          params.permit(:contract_id, :doc_no, :order_company, :order_contract_no, :goods_name, :specs, :order_kind, :special_note, :qty, :qty_unit, :pack_specs, :deliver_at, :notes, :user_id, :reviewer_id, :review_at, :prod_signer_id, :tech_signer_id, :qa_signer_id, :user_id, :updater_id, :py)
        end

        def handover_lines_params
          params[:lines] || params.dig(:handover, :lines) || []
        end

        def create_handover_lines
          lines = Array(handover_lines_params)
          lines.each do |line_attrs|
            attrs = line_attrs.respond_to?(:to_unsafe_h) ? line_attrs.to_unsafe_h : line_attrs.to_h
            @handovers.handover_lines.create!(
              spec_item_id: attrs["spec_item_id"] || attrs[:spec_item_id],
              contract_req: attrs["contract_req"] || attrs[:contract_req],
              internal_req: attrs["internal_req"] || attrs[:internal_req],
              sort: attrs["sort"] || attrs[:sort] || 0,
              user_id: @current_user&.id
            )
          end
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
            authorize!(params[:action].to_sym, @handovers || ::Crm::Handover)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
