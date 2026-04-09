module Api
  module V1
    class Mfg::PkgLinesController < BaseController
      before_action :set_pkg_lines, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/pkg_lines
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/pkg lines列表")
        
        # 基础查询
        query = ::Mfg::PkgLine.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mfg::PkgLine.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @pkg_lines = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @pkg_lines = @pkg_lines.where(parent_id: nil) if ::Mfg::PkgLine.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @pkg_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @pkg_lines.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @pkg_lines = @pkg_lines.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @pkg_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/pkg_lines/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@pkg_lines) ? @pkg_lines.base_info : @pkg_lines.attributes 
        }
      end

      # POST /api/v1/pkg_lines
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mfg::PkgLine.column_names.include?("parent_id")
          pkg_lines_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @pkg_lines = ::Mfg::PkgLine.new(pkg_lines_params)

        if @pkg_lines.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mfg::PkgLine.column_names.include?("parent_id") && params["parent_id"] != 0
            @pkg_lines.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/pkg lines#{@pkg_lines.name rescue @pkg_lines.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@pkg_lines) ? @pkg_lines.base_info : @pkg_lines.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/pkg lines失败: #{@pkg_lines.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @pkg_lines.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/pkg_lines/1
      def update
        if @pkg_lines.update(pkg_lines_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mfg::PkgLine.column_names.include?("parent_id")
            @pkg_lines.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@pkg_lines) ? @pkg_lines.base_info : @pkg_lines.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/pkg lines修改#{@pkg_lines.name rescue @pkg_lines.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/pkg lines修改#{@pkg_lines.name rescue @pkg_lines.id} 失败: #{@pkg_lines.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @pkg_lines.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/pkg_lines/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/pkg lines删除#{@pkg_lines.name rescue @pkg_lines.id}成功")
        @pkg_lines.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/pkg_lines_trees
      def pkg_lines_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/pkg lines树状列表")
        
        # 基础查询
        query = ::Mfg::PkgLine.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mfg::PkgLine.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mfg::PkgLine.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @pkg_lines = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @pkg_lines.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @pkg_lines.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/pkg_lines/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::PkgLine.respond_to?(:imp_exp_hander) ? ::Mfg::PkgLine.imp_exp_hander : ::Mfg::PkgLine.column_names
          i18n_column_names = ::Mfg::PkgLine.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::PkgLine.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/pkg lines模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mfg::PkgLine.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/pkg lines预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/pkg_lines/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:pkg_lines].blank?

          ::Mfg::PkgLine.transaction do
            params[:pkg_lines].each do |pkg_lines_params|
              pkg_lines = ::Mfg::PkgLine.new(pkg_lines_params.to_unsafe_h)
              if pkg_lines.save
                pkg_lines.update_columns(parent_id: pkg_lines_params[:parent_id]) if pkg_lines_params[:parent_id].present? && ::Mfg::PkgLine.column_names.include?("parent_id")
                results[:success] += 1
                data << pkg_lines
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/pkg lines#{pkg_lines.name rescue pkg_lines.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: pkg_lines_params, errors: pkg_lines.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/pkg lines#{pkg_lines_params[:name]}失败: #{pkg_lines.errors.full_messages.join(",")}")
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

          ::Mfg::PkgLine.transaction do
            selected_ids.each do |pkg_lines_id|
              pkg_lines = ::Mfg::PkgLine.find_by(id: pkg_lines_id)
              if pkg_lines
                if pkg_lines.update(update_params)
                  # 处理parent_id更新（如果需要）
                  pkg_lines.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mfg::PkgLine.column_names.include?("parent_id")
                  results[:success] += 1
                  data << pkg_lines
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/pkg lines#{pkg_lines.name rescue pkg_lines.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: pkg_lines_id, errors: pkg_lines.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/pkg lines#{pkg_lines.name rescue pkg_lines.id}失败: #{pkg_lines.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: pkg_lines_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/pkg lines失败: 记录ID #{pkg_lines_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mfg::PkgLine.transaction do
            params[:ids].each do |pkg_lines_id|
              pkg_lines = ::Mfg::PkgLine.find(pkg_lines_id)
              if pkg_lines
                pkg_lines.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/pkg lines#{pkg_lines.name rescue pkg_lines.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: pkg_lines_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/pkg lines失败: 记录ID #{pkg_lines_id} 不存在")
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
        def set_pkg_lines
          @pkg_lines = ::Mfg::PkgLine.find(params[:id]) rescue nil
          if @pkg_lines.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def pkg_lines_params
          params.permit(:contract_id, :pkg_handover_id, :line_id, :record_date, :weather, :temperature, :product_id, :name, :code, :customer_trademark_name, :planned_total_qty_kl, :planned_total_pieces, :packaging_batch_number, :semi_finished_batch_number, :specific_gravity, :packaging_spec, :net_weight_per_bottle, :empty_bottle_weight, :filling_range, :standard_weight_per_bottle, :standard_weight_per_box, :packaging_key_points, :formal_filling_start_time, :formal_filling_end_time, :packages_this_shift, :filling_debug_air_pressure, :filling_debug_temperature, :filling_debug_horizontal_temp, :filling_debug_vertical_temp, :filling_debug_notes, :labeling_machine_result, :filling_machine_result, :capping_machine_result, :sealing_machine_result, :coding_machine_result, :shrink_film_machine_result, :packing_machine_result, :operator_info, :line_foreman_id, :other, :remark, :user_id)
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
            authorize!(params[:action].to_sym, @pkg_lines || ::Mfg::PkgLine)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
