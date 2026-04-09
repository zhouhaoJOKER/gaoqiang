module Api
  module V1
    class Mfg::DisassemblyOrdersController < BaseController
      before_action :set_disassembly_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/disassembly_order列表")
        query = ::Mfg::DisassemblyOrder.order("id desc")
        begin
          associations = [:user, :updater, :product, :item, :lot]
          associations.select! { |assoc| ::Mfg::DisassemblyOrder.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @disassembly_orders = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @disassembly_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @disassembly_orders.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @disassembly_orders = @disassembly_orders.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @disassembly_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@disassembly_order) ? @disassembly_order.base_info : @disassembly_order.attributes }
      end

      def create
        @disassembly_order = ::Mfg::DisassemblyOrder.new(disassembly_order_params)
        @disassembly_order.user_id = @current_user.id if @disassembly_order.respond_to?(:user_id) && @disassembly_order.user_id.nil?
        if @disassembly_order.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/disassembly_order#{@disassembly_order.code rescue @disassembly_order.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@disassembly_order) ? @disassembly_order.base_info : @disassembly_order.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/disassembly_order失败: #{@disassembly_order.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @disassembly_order.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        disassembly_order_params_hash = disassembly_order_params.to_h
        disassembly_order_params_hash[:updater_id] = @current_user.id if @disassembly_order.respond_to?(:updater_id)
        if @disassembly_order.update(disassembly_order_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@disassembly_order) ? @disassembly_order.base_info : @disassembly_order.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/disassembly_order修改#{@disassembly_order.code rescue @disassembly_order.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/disassembly_order修改#{@disassembly_order.code rescue @disassembly_order.id} 失败: #{@disassembly_order.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @disassembly_order.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/disassembly_order删除#{@disassembly_order.code rescue @disassembly_order.id}成功")
        @disassembly_order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::DisassemblyOrder.respond_to?(:imp_exp_hander) ? ::Mfg::DisassemblyOrder.imp_exp_hander : ::Mfg::DisassemblyOrder.column_names
          i18n_column_names = ::Mfg::DisassemblyOrder.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::DisassemblyOrder.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/disassembly_order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::DisassemblyOrder.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/disassembly_order预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?
        action = params[:actions]
        valid_actions = [ "create", "update", "delete" ]
        return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
        data = []
        results = { success: 0, failed: 0, errors: [] }
        case action
        when "create"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:disassembly_orders].blank?
          ::Mfg::DisassemblyOrder.transaction do
            params[:disassembly_orders].each do |disassembly_order_params|
              disassembly_order = ::Mfg::DisassemblyOrder.new(disassembly_order_params.to_unsafe_h)
              if disassembly_order.save
                results[:success] += 1
                data << disassembly_order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/disassembly_order#{disassembly_order.code rescue disassembly_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: disassembly_order_params, errors: disassembly_order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/disassembly_order#{disassembly_order_params[:code]}失败: #{disassembly_order.errors.full_messages.join(",")}")
              end
            end
          end
        when "update"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?
          selected_ids = params[:ids]
          fields = params[:fields]
          values = params[:values]
          update_params = {}
          fields.each do |field|
            update_params[field.to_sym] = values[field] if values.key?(field)
          end
          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?
          ::Mfg::DisassemblyOrder.transaction do
            selected_ids.each do |disassembly_order_id|
              disassembly_order = ::Mfg::DisassemblyOrder.find_by(id: disassembly_order_id)
              if disassembly_order
                if disassembly_order.update(update_params)
                  results[:success] += 1
                  data << disassembly_order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/disassembly_order#{disassembly_order.code rescue disassembly_order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: disassembly_order_id, errors: disassembly_order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/disassembly_order#{disassembly_order.code rescue disassembly_order.id}失败: #{disassembly_order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: disassembly_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/disassembly_order失败: 记录ID #{disassembly_order_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::DisassemblyOrder.transaction do
            params[:ids].each do |disassembly_order_id|
              disassembly_order = ::Mfg::DisassemblyOrder.find(disassembly_order_id)
              if disassembly_order
                disassembly_order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/disassembly_order#{disassembly_order.code rescue disassembly_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: disassembly_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/disassembly_order失败: 记录ID #{disassembly_order_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_disassembly_order
          @disassembly_order = ::Mfg::DisassemblyOrder.find(params[:id]) rescue nil
          if @disassembly_order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def disassembly_order_params
          params.permit(:code, :product_id, :item_id, :lot_id, :planned_qty, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @disassembly_order || ::Mfg::DisassemblyOrder)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
