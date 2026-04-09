module Api
  module V1
    class Inv::InventoryLocksController < BaseController
      before_action :set_inventory_lock, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Inv/inventory_lock列表")
        query = ::Inv::InventoryLock.order("id desc")
        begin
          associations = [:item, :location, :inventory, :user, :updater]
          associations.select! { |assoc| ::Inv::InventoryLock.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @inventory_locks = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @inventory_locks.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @inventory_locks.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @inventory_locks = @inventory_locks.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @inventory_locks.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@inventory_lock) ? @inventory_lock.base_info : @inventory_lock.attributes }
      end

      def create
        @inventory_lock = ::Inv::InventoryLock.new(inventory_lock_params)
        @inventory_lock.user_id = @current_user.id if @inventory_lock.respond_to?(:user_id) && @inventory_lock.user_id.nil?
        if @inventory_lock.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Inv/inventory_lock#{@inventory_lock.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@inventory_lock) ? @inventory_lock.base_info : @inventory_lock.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Inv/inventory_lock失败: #{@inventory_lock.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @inventory_lock.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        inventory_lock_params_hash = inventory_lock_params.to_h
        inventory_lock_params_hash[:updater_id] = @current_user.id if @inventory_lock.respond_to?(:updater_id)
        if @inventory_lock.update(inventory_lock_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@inventory_lock) ? @inventory_lock.base_info : @inventory_lock.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/inventory_lock修改#{@inventory_lock.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Inv/inventory_lock修改#{@inventory_lock.id} 失败: #{@inventory_lock.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @inventory_lock.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/inventory_lock删除#{@inventory_lock.id}成功")
        @inventory_lock.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Inv::InventoryLock.respond_to?(:imp_exp_hander) ? ::Inv::InventoryLock.imp_exp_hander : ::Inv::InventoryLock.column_names
          i18n_column_names = ::Inv::InventoryLock.respond_to?(:il8n_imp_exp_hander) ? ::Inv::InventoryLock.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Inv/inventory_lock模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
          attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Inv::InventoryLock.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Inv/inventory_lock预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:inventory_locks].blank?
          ::Inv::InventoryLock.transaction do
            params[:inventory_locks].each do |inventory_lock_params|
              inventory_lock = ::Inv::InventoryLock.new(inventory_lock_params.to_unsafe_h)
              if inventory_lock.save
                results[:success] += 1
                data << inventory_lock
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Inv/inventory_lock#{inventory_lock.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: inventory_lock_params, errors: inventory_lock.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Inv/inventory_lock失败: #{inventory_lock.errors.full_messages.join(",")}")
              end
            end
          end
        when "update"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?
          selected_ids = params[:ids]
          fields = params[:fields]
          values = params[:values]
          update_params = {}
          fields.each { |field| update_params[field.to_sym] = values[field] if values.key?(field) }
          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?
          ::Inv::InventoryLock.transaction do
            selected_ids.each do |inventory_lock_id|
              inventory_lock = ::Inv::InventoryLock.find_by(id: inventory_lock_id)
              if inventory_lock
                if inventory_lock.update(update_params)
                  results[:success] += 1
                  data << inventory_lock
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Inv/inventory_lock#{inventory_lock.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: inventory_lock_id, errors: inventory_lock.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/inventory_lock#{inventory_lock.id}失败: #{inventory_lock.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: inventory_lock_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/inventory_lock失败: 记录ID #{inventory_lock_id} 不存在")
              end
            end
          end
        when "delete"
          ::Inv::InventoryLock.transaction do
            params[:ids].each do |inventory_lock_id|
              inventory_lock = ::Inv::InventoryLock.find(inventory_lock_id)
              if inventory_lock
                inventory_lock.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Inv/inventory_lock#{inventory_lock.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: inventory_lock_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Inv/inventory_lock失败: 记录ID #{inventory_lock_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_inventory_lock
          @inventory_lock = ::Inv::InventoryLock.find(params[:id]) rescue nil
          if @inventory_lock.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def inventory_lock_params
          params.permit(:item_id, :location_id, :inventory_id, :locked_qty, :order_type, :order_id, :lock_type, :status, :expires_at, :user_id, :updater_id)
        end

        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end

        def check_authorize
          begin
            authorize!(params[:action].to_sym, @inventory_lock || ::Inv::InventoryLock)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
