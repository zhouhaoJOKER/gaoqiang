module Api
  module V1
    class Mfg::OrderLinesController < BaseController
      before_action :set_order_line, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/order_line列表")
        query = ::Mfg::OrderLine.order("id desc")
        begin
          associations = [:order, :user, :updater, :product, :item, :bom_line]
          associations.select! { |assoc| ::Mfg::OrderLine.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @order_lines = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @order_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @order_lines.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @order_lines = @order_lines.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @order_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@order_line) ? @order_line.base_info : @order_line.attributes }
      end

      def create
        @order_line = ::Mfg::OrderLine.new(order_line_params)
        @order_line.user_id = @current_user.id if @order_line.respond_to?(:user_id) && @order_line.user_id.nil?
        if @order_line.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/order_line#{@order_line.code rescue @order_line.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@order_line) ? @order_line.base_info : @order_line.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/order_line失败: #{@order_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        order_line_params_hash = order_line_params.to_h
        order_line_params_hash[:updater_id] = @current_user.id if @order_line.respond_to?(:updater_id)
        if @order_line.update(order_line_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@order_line) ? @order_line.base_info : @order_line.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/order_line修改#{@order_line.code rescue @order_line.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/order_line修改#{@order_line.code rescue @order_line.id} 失败: #{@order_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/order_line删除#{@order_line.code rescue @order_line.id}成功")
        @order_line.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::OrderLine.respond_to?(:imp_exp_hander) ? ::Mfg::OrderLine.imp_exp_hander : ::Mfg::OrderLine.column_names
          i18n_column_names = ::Mfg::OrderLine.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::OrderLine.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/order_line模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::OrderLine.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/order_line预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:order_lines].blank?
          ::Mfg::OrderLine.transaction do
            params[:order_lines].each do |order_line_params|
              order_line = ::Mfg::OrderLine.new(order_line_params.to_unsafe_h)
              if order_line.save
                results[:success] += 1
                data << order_line
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/order_line#{order_line.code rescue order_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: order_line_params, errors: order_line.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/order_line#{order_line_params[:code]}失败: #{order_line.errors.full_messages.join(",")}")
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
          ::Mfg::OrderLine.transaction do
            selected_ids.each do |order_line_id|
              order_line = ::Mfg::OrderLine.find_by(id: order_line_id)
              if order_line
                if order_line.update(update_params)
                  results[:success] += 1
                  data << order_line
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/order_line#{order_line.code rescue order_line.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: order_line_id, errors: order_line.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/order_line#{order_line.code rescue order_line.id}失败: #{order_line.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: order_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/order_line失败: 记录ID #{order_line_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::OrderLine.transaction do
            params[:ids].each do |order_line_id|
              order_line = ::Mfg::OrderLine.find(order_line_id)
              if order_line
                order_line.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/order_line#{order_line.code rescue order_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: order_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/order_line失败: 记录ID #{order_line_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_order_line
          @order_line = ::Mfg::OrderLine.find(params[:id]) rescue nil
          if @order_line.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def order_line_params
          params.permit(:order_id, :product_id, :item_id, :bom_line_id, :required_date, :required_qty, :allocated_qty, :available_qty, :shortage_qty, :status, :is_alternative, :alternative_for_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @order_line || ::Mfg::OrderLine)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
