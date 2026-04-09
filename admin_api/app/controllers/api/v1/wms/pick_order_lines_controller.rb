module Api
  module V1
    class Wms::PickOrderLinesController < BaseController
      before_action :set_pick_order_line, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wms/pick_order_line列表")
        query = ::Wms::PickOrderLine.order("id desc")
        begin
          associations = [:user, :updater, :pick_order, :item]
          associations.select! { |assoc| ::Wms::PickOrderLine.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @pick_order_lines = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @pick_order_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @pick_order_lines.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @pick_order_lines = @pick_order_lines.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @pick_order_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@pick_order_line) ? @pick_order_line.base_info : @pick_order_line.attributes }
      end

      def create
        @pick_order_line = ::Wms::PickOrderLine.new(pick_order_line_params)
        @pick_order_line.user_id = @current_user.id if @pick_order_line.respond_to?(:user_id) && @pick_order_line.user_id.nil?
        if @pick_order_line.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Wms/pick_order_line#{@pick_order_line.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@pick_order_line) ? @pick_order_line.base_info : @pick_order_line.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/pick_order_line失败: #{@pick_order_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @pick_order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        pick_order_line_params_hash = pick_order_line_params.to_h
        pick_order_line_params_hash[:updater_id] = @current_user.id if @pick_order_line.respond_to?(:updater_id)
        if @pick_order_line.update(pick_order_line_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@pick_order_line) ? @pick_order_line.base_info : @pick_order_line.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/pick_order_line修改#{@pick_order_line.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Wms/pick_order_line修改#{@pick_order_line.id} 失败: #{@pick_order_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @pick_order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/pick_order_line删除#{@pick_order_line.id}成功")
        @pick_order_line.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Wms::PickOrderLine.respond_to?(:imp_exp_hander) ? ::Wms::PickOrderLine.imp_exp_hander : ::Wms::PickOrderLine.column_names
          i18n_column_names = ::Wms::PickOrderLine.respond_to?(:il8n_imp_exp_hander) ? ::Wms::PickOrderLine.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Wms/pick_order_line模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Wms::PickOrderLine.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Wms/pick_order_line预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:pick_order_lines].blank?
          ::Wms::PickOrderLine.transaction do
            params[:pick_order_lines].each do |pick_order_line_params|
              pick_order_line = ::Wms::PickOrderLine.new(pick_order_line_params.to_unsafe_h)
              if pick_order_line.save
                results[:success] += 1
                data << pick_order_line
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Wms/pick_order_line#{pick_order_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: pick_order_line_params, errors: pick_order_line.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Wms/pick_order_line失败: #{pick_order_line.errors.full_messages.join(",")}")
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
          ::Wms::PickOrderLine.transaction do
            selected_ids.each do |pick_order_line_id|
              pick_order_line = ::Wms::PickOrderLine.find_by(id: pick_order_line_id)
              if pick_order_line
                if pick_order_line.update(update_params)
                  results[:success] += 1
                  data << pick_order_line
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Wms/pick_order_line#{pick_order_line.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: pick_order_line_id, errors: pick_order_line.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/pick_order_line#{pick_order_line.id}失败: #{pick_order_line.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: pick_order_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/pick_order_line失败: 记录ID #{pick_order_line_id} 不存在")
              end
            end
          end
        when "delete"
          ::Wms::PickOrderLine.transaction do
            params[:ids].each do |pick_order_line_id|
              pick_order_line = ::Wms::PickOrderLine.find(pick_order_line_id)
              if pick_order_line
                pick_order_line.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Wms/pick_order_line#{pick_order_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: pick_order_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Wms/pick_order_line失败: 记录ID #{pick_order_line_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_pick_order_line
          @pick_order_line = ::Wms::PickOrderLine.find(params[:id]) rescue nil
          if @pick_order_line.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def pick_order_line_params
          params.permit(:pick_order_id, :item_id, :location_id, :plan_qty, :picked_qty, :status, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @pick_order_line || ::Wms::PickOrderLine)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
