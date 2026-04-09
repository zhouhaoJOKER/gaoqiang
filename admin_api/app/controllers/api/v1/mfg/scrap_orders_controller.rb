module Api
  module V1
    class Mfg::ScrapOrdersController < BaseController
      before_action :set_scrap_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/scrap_order列表")
        query = ::Mfg::ScrapOrder.order("id desc")
        begin
          associations = [:user, :updater, :product, :item, :lot]
          associations.select! { |assoc| ::Mfg::ScrapOrder.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @scrap_orders = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @scrap_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @scrap_orders.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @scrap_orders = @scrap_orders.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @scrap_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@scrap_order) ? @scrap_order.base_info : @scrap_order.attributes }
      end

      def create
        @scrap_order = ::Mfg::ScrapOrder.new(scrap_order_params)
        @scrap_order.user_id = @current_user.id if @scrap_order.respond_to?(:user_id) && @scrap_order.user_id.nil?
        if @scrap_order.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/scrap_order#{@scrap_order.code rescue @scrap_order.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@scrap_order) ? @scrap_order.base_info : @scrap_order.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/scrap_order失败: #{@scrap_order.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @scrap_order.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        scrap_order_params_hash = scrap_order_params.to_h
        scrap_order_params_hash[:updater_id] = @current_user.id if @scrap_order.respond_to?(:updater_id)
        if @scrap_order.update(scrap_order_params_hash)
          # 报废单状态变更为已完成时，同步库存（减少对应货位数量）
          if @scrap_order.respond_to?(:status) && Inv::InventoryService.completed?(@scrap_order.status)
            begin
              @scrap_order.sync_inventory_on_complete!(operator_id: @current_user.id)
              gen_log(@current_user.id, @current_ip, "sync_inventory", 1, "报废单#{@scrap_order.code}完成，库存同步成功")
            rescue => e
              gen_log(@current_user.id, @current_ip, "sync_inventory", 0, "报废单#{@scrap_order.code}库存同步失败: #{e.message}")
              return render json: { code: 500, success: 0, msg: "报废单更新成功，但库存同步失败: #{e.message}", data: "" }
            end
          end
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@scrap_order) ? @scrap_order.base_info : @scrap_order.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/scrap_order修改#{@scrap_order.code rescue @scrap_order.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/scrap_order修改#{@scrap_order.code rescue @scrap_order.id} 失败: #{@scrap_order.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @scrap_order.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/scrap_order删除#{@scrap_order.code rescue @scrap_order.id}成功")
        @scrap_order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::ScrapOrder.respond_to?(:imp_exp_hander) ? ::Mfg::ScrapOrder.imp_exp_hander : ::Mfg::ScrapOrder.column_names
          i18n_column_names = ::Mfg::ScrapOrder.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::ScrapOrder.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/scrap_order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::ScrapOrder.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/scrap_order预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:scrap_orders].blank?
          ::Mfg::ScrapOrder.transaction do
            params[:scrap_orders].each do |scrap_order_params|
              scrap_order = ::Mfg::ScrapOrder.new(scrap_order_params.to_unsafe_h)
              if scrap_order.save
                results[:success] += 1
                data << scrap_order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/scrap_order#{scrap_order.code rescue scrap_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: scrap_order_params, errors: scrap_order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/scrap_order#{scrap_order_params[:code]}失败: #{scrap_order.errors.full_messages.join(",")}")
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
          ::Mfg::ScrapOrder.transaction do
            selected_ids.each do |scrap_order_id|
              scrap_order = ::Mfg::ScrapOrder.find_by(id: scrap_order_id)
              if scrap_order
                if scrap_order.update(update_params)
                  if scrap_order.respond_to?(:status) && Inv::InventoryService.completed?(scrap_order.status)
                    begin
                      scrap_order.sync_inventory_on_complete!(operator_id: @current_user.id)
                    rescue => e
                      gen_log(@current_user.id, @current_ip, "batch_sync_inventory", 0, "报废单#{scrap_order.code}库存同步失败: #{e.message}")
                    end
                  end
                  results[:success] += 1
                  data << scrap_order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/scrap_order#{scrap_order.code rescue scrap_order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: scrap_order_id, errors: scrap_order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/scrap_order#{scrap_order.code rescue scrap_order.id}失败: #{scrap_order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: scrap_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/scrap_order失败: 记录ID #{scrap_order_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::ScrapOrder.transaction do
            params[:ids].each do |scrap_order_id|
              scrap_order = ::Mfg::ScrapOrder.find(scrap_order_id)
              if scrap_order
                scrap_order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/scrap_order#{scrap_order.code rescue scrap_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: scrap_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/scrap_order失败: 记录ID #{scrap_order_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_scrap_order
          @scrap_order = ::Mfg::ScrapOrder.find(params[:id]) rescue nil
          if @scrap_order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def scrap_order_params
          params.permit(:code, :scrap_category, :product_id, :item_id, :lot_id, :location_id, :planned_qty, :status, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @scrap_order || ::Mfg::ScrapOrder)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
