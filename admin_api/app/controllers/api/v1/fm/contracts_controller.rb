module Api
  module V1
    class Fm::ContractsController < BaseController
      before_action :set_contracts, only: [:show, :update, :destroy, :workflow_logs, :create_workflow_log, :workflow_states, :update_workflow_states, :workflow_definition]
      before_action :check_authorize

      # GET /api/v1/contracts
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Fm/contracts列表")
        
        # 基础查询
        query = ::Fm::Contract.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Fm::Contract.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @contracts = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @contracts = @contracts.where(parent_id: nil) if ::Fm::Contract.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @contracts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @contracts.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @contracts = @contracts.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @contracts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/fm/contracts/:id
      def show
        data = model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes
        # 合同详情页需包含流程数据（目录流程 + 流程图）
        data = data.merge(workflow_data_for_contract(@contracts)) if data.is_a?(Hash)
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: data
        }
      end

      # POST /api/v1/contracts
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Fm::Contract.column_names.include?("parent_id")
          contracts_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @contracts = ::Fm::Contract.new(contracts_params)

        if @contracts.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Fm::Contract.column_names.include?("parent_id") && params["parent_id"] != 0
            @contracts.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Fm/contracts#{@contracts.name rescue @contracts.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Fm/contracts失败: #{@contracts.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @contracts.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/contracts/1
      def update
        if @contracts.update(contracts_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Fm::Contract.column_names.include?("parent_id")
            @contracts.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Fm/contracts修改#{@contracts.name rescue @contracts.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Fm/contracts修改#{@contracts.name rescue @contracts.id} 失败: #{@contracts.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @contracts.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/contracts/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Fm/contracts删除#{@contracts.name rescue @contracts.id}成功")
        @contracts.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/contracts_trees
      def contracts_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Fm/contracts树状列表")
        
        # 基础查询
        query = ::Fm::Contract.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Fm::Contract.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Fm::Contract.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @contracts = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @contracts.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @contracts.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # GET /api/v1/fm/contracts/:id/workflow_logs
      def workflow_logs
        logs = @contracts.workflow_logs.order(:sort, :operated_at)
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: logs.map { |l| l.base_info }
        }
      end

      # POST /api/v1/fm/contracts/:id/workflow_logs
      def create_workflow_log
        log = @contracts.workflow_logs.build(workflow_log_params)
        log.operator_id = @current_user.id
        log.operator_name = @current_user.name
        log.operated_at ||= Time.current
        log.sort = (@contracts.workflow_logs.maximum(:sort) || -1) + 1
        if log.save
          FmContractWorkflowService.advance_state(@contracts, log.step_key, log.result, operator: @current_user)
          render json: { code: 200, success: 1, msg: "ok", data: log.base_info }
        else
          render json: { code: 422, success: 0, msg: log.errors.full_messages.join(", "), data: nil }
        end
      end

      # GET /api/v1/fm/contracts/:id/workflow_states
      def workflow_states
        states = @contracts.workflow_states.order(:step_key)
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: states.map { |s| s.base_info }
        }
      end

      # PUT /api/v1/fm/contracts/:id/workflow_states
      def update_workflow_states
        # 支持单条更新 step_key 或批量更新 states 数组
        if params[:step_key].present?
          state = @contracts.workflow_states.find_or_initialize_by(step_key: params[:step_key])
          state.contract_id = @contracts.id
          if state.update(workflow_state_params)
            render json: { code: 200, success: 1, msg: "ok", data: state.base_info }
          else
            render json: { code: 422, success: 0, msg: state.errors.full_messages.join(", "), data: nil }
          end
        elsif params[:states].is_a?(Array)
          updated = []
          params[:states].each do |s|
            key = s[:step_key] || s["step_key"]
            next if key.blank?
            state = @contracts.workflow_states.find_or_initialize_by(step_key: key)
            state.contract_id = @contracts.id
            attrs = {}
            attrs[:status] = s[:status] || s["status"] if (s[:status] || s["status"]).present?
            attrs[:completed_at] = s[:completed_at] || s["completed_at"] if (s[:completed_at] || s["completed_at"]).present?
            attrs[:result] = s[:result] || s["result"] if s.key?(:result) || s.key?("result")
            state.update(attrs) if attrs.any?
            updated << state.base_info
          end
          render json: { code: 200, success: 1, msg: "ok", data: updated }
        else
          render json: { code: 422, success: 0, msg: "请提供 step_key 或 states 数组", data: nil }
        end
      end

      # GET /api/v1/fm/contracts/:id/workflow_definition
      def workflow_definition
        template = @contracts.workflow_template || ::Workflow::Template.default_template
        return render json: { code: 200, success: 1, msg: "ok", data: { nodes: [], edges: [], node_results: [], states: [] } } unless template

        nodes = template.nodes.order(:sort)
        edges = template.edges.order(:sort)
        node_results = template.node_results
        states = @contracts.workflow_states.index_by(&:step_key)

        # Vue Flow 格式（与 workflow_data_example.json 一致，position 确保为整数）
        vue_nodes = nodes.map do |n|
          state = states[n.key]
          {
            id: n.key,
            type: (n.node_type.presence || "workflow"),
            position: { x: n.position_x.to_i, y: n.position_y.to_i },
            data: { key: n.key, label: n.label, status: (state&.status || "pending") }
          }
        end

        vue_edges = edges.map do |e|
          {
            id: "e-#{e.source_key}-#{e.target_key}#{e.result_value.present? ? "-#{e.result_value}" : ""}",
            source: e.source_key,
            target: e.target_key,
            data: e.label.present? ? { label: e.label } : nil
          }
        end

        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: {
            template_id: template.id,
            template_name: template.name,
            nodes: vue_nodes,
            edges: vue_edges,
            node_results: node_results.map { |r| { node_key: r.node_key, result_value: r.result_value, result_label: r.result_label, target_key: r.target_key } },
            states: @contracts.workflow_states.map { |s| s.base_info }
          }
        }
      end

      # 导入功能
      # post api/v1/contracts/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Fm::Contract.respond_to?(:imp_exp_hander) ? ::Fm::Contract.imp_exp_hander : ::Fm::Contract.column_names
          i18n_column_names = ::Fm::Contract.respond_to?(:il8n_imp_exp_hander) ? ::Fm::Contract.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Fm/contracts模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Fm::Contract.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Fm/contracts预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/contracts/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:contracts].blank?

          ::Fm::Contract.transaction do
            params[:contracts].each do |contracts_params|
              contracts = ::Fm::Contract.new(contracts_params.to_unsafe_h)
              if contracts.save
                contracts.update_columns(parent_id: contracts_params[:parent_id]) if contracts_params[:parent_id].present? && ::Fm::Contract.column_names.include?("parent_id")
                results[:success] += 1
                data << contracts
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Fm/contracts#{contracts.name rescue contracts.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: contracts_params, errors: contracts.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Fm/contracts#{contracts_params[:name]}失败: #{contracts.errors.full_messages.join(",")}")
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

          ::Fm::Contract.transaction do
            selected_ids.each do |contracts_id|
              contracts = ::Fm::Contract.find_by(id: contracts_id)
              if contracts
                if contracts.update(update_params)
                  # 处理parent_id更新（如果需要）
                  contracts.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Fm::Contract.column_names.include?("parent_id")
                  results[:success] += 1
                  data << contracts
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Fm/contracts#{contracts.name rescue contracts.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: contracts_id, errors: contracts.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Fm/contracts#{contracts.name rescue contracts.id}失败: #{contracts.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: contracts_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Fm/contracts失败: 记录ID #{contracts_id} 不存在")
              end
            end
          end

        when "delete"
          ::Fm::Contract.transaction do
            params[:ids].each do |contracts_id|
              contracts = ::Fm::Contract.find(contracts_id)
              if contracts
                contracts.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Fm/contracts#{contracts.name rescue contracts.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: contracts_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Fm/contracts失败: 记录ID #{contracts_id} 不存在")
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
        def set_contracts
          @contracts = ::Fm::Contract.find(params[:id]) rescue nil
          if @contracts.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def contracts_params
          params.permit(:code, :sign_at, :client_id, :client_contact_name, :client_contact_id, :client_phone, :client_fax, :supplier_id, :supplier_contact_id, :supplier_contact_name, :supplier_phone, :supplier_fax, :product_id, :product_en, :product_zh, :specs, :pack_req, :unit_id, :qty, :unit_price, :total, :tax, :tax_id, :amount_net, :total_cn, :deliver_at, :deliver_addr, :indicator_req, :req_docs, :settlement_id, :remarks, :user_id, :updater_id, :py, :workflow_template_id)
        end

        def workflow_log_params
          params.permit(:step_key, :step_label, :action, :result, :operated_at, result_extra: {})
        end

        def workflow_state_params
          params.permit(:status, :completed_at, :result)
        end

        # 合同详情页所需的流程数据：workflow_logs、workflow_states、workflow_definition（Vue Flow 格式）
        def workflow_data_for_contract(contract)
          template = contract.workflow_template || ::Workflow::Template.default_template
          logs = contract.workflow_logs.order(:sort, :operated_at).map(&:base_info)
          states = contract.workflow_states.order(:step_key).map(&:base_info)
          states_by_key = contract.workflow_states.index_by(&:step_key)

          if template.blank?
            return {
              workflow_logs: logs,
              workflow_states: states,
              workflow_definition: {
                template_id: nil,
                template_name: nil,
                nodes: [],
                edges: [],
                node_results: [],
                states: states
              }
            }
          end

          nodes = template.nodes.order(:sort)
          edges = template.edges.order(:sort)
          node_results = template.node_results

          # Vue Flow 格式（与 workflow_data_example.json 一致）
          vue_nodes = nodes.map do |n|
            state = states_by_key[n.key]
            {
              id: n.key,
              type: (n.node_type.presence || "workflow"),
              position: { x: n.position_x.to_i, y: n.position_y.to_i },
              data: { key: n.key, label: n.label, status: (state&.status || "pending") }
            }
          end

          vue_edges = edges.map do |e|
            {
              id: "e-#{e.source_key}-#{e.target_key}#{e.result_value.present? ? "-#{e.result_value}" : ""}",
              source: e.source_key,
              target: e.target_key,
              data: e.label.present? ? { label: e.label } : nil
            }
          end

          {
            workflow_logs: logs,
            workflow_states: states,
            workflow_definition: {
              template_id: template.id,
              template_name: template.name,
              nodes: vue_nodes,
              edges: vue_edges,
              node_results: node_results.map { |r| { node_key: r.node_key, result_value: r.result_value, result_label: r.result_label, target_key: r.target_key } },
              states: states
            }
          }
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
            authorize!(params[:action].to_sym, @contracts || ::Fm::Contract)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
