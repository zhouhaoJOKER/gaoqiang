module Api
  module V1
    class Inv::InventoryTransactionsController < BaseController
      before_action :set_inventory_transaction, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Inv/inventory_transaction列表")
        query = ::Inv::InventoryTransaction.order("id desc")
        begin
          associations = [:item, :location, :inventory, :user, :updater, :operator]
          associations.select! { |assoc| ::Inv::InventoryTransaction.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @inventory_transactions = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @inventory_transactions.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @inventory_transactions.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @inventory_transactions = @inventory_transactions.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @inventory_transactions.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@inventory_transaction) ? @inventory_transaction.base_info : @inventory_transaction.attributes }
      end

      def create
        @inventory_transaction = ::Inv::InventoryTransaction.new(inventory_transaction_params)
        @inventory_transaction.user_id = @current_user.id if @inventory_transaction.respond_to?(:user_id) && @inventory_transaction.user_id.nil?
        @inventory_transaction.operator_id = @current_user.id if @inventory_transaction.respond_to?(:operator_id) && @inventory_transaction.operator_id.nil?
        @inventory_transaction.transaction_time = Time.current if @inventory_transaction.respond_to?(:transaction_time) && @inventory_transaction.transaction_time.nil?
        if @inventory_transaction.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Inv/inventory_transaction#{@inventory_transaction.code rescue @inventory_transaction.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@inventory_transaction) ? @inventory_transaction.base_info : @inventory_transaction.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Inv/inventory_transaction失败: #{@inventory_transaction.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @inventory_transaction.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        inventory_transaction_params_hash = inventory_transaction_params.to_h
        inventory_transaction_params_hash[:updater_id] = @current_user.id if @inventory_transaction.respond_to?(:updater_id)
        if @inventory_transaction.update(inventory_transaction_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@inventory_transaction) ? @inventory_transaction.base_info : @inventory_transaction.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/inventory_transaction修改#{@inventory_transaction.code rescue @inventory_transaction.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Inv/inventory_transaction修改#{@inventory_transaction.code rescue @inventory_transaction.id} 失败: #{@inventory_transaction.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @inventory_transaction.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/inventory_transaction删除#{@inventory_transaction.code rescue @inventory_transaction.id}成功")
        @inventory_transaction.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Inv::InventoryTransaction.respond_to?(:imp_exp_hander) ? ::Inv::InventoryTransaction.imp_exp_hander : ::Inv::InventoryTransaction.column_names
          i18n_column_names = ::Inv::InventoryTransaction.respond_to?(:il8n_imp_exp_hander) ? ::Inv::InventoryTransaction.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Inv/inventory_transaction模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
          attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Inv::InventoryTransaction.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Inv/inventory_transaction预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:inventory_transactions].blank?
          ::Inv::InventoryTransaction.transaction do
            params[:inventory_transactions].each do |inventory_transaction_params|
              inventory_transaction = ::Inv::InventoryTransaction.new(inventory_transaction_params.to_unsafe_h)
              if inventory_transaction.save
                results[:success] += 1
                data << inventory_transaction
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Inv/inventory_transaction#{inventory_transaction.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: inventory_transaction_params, errors: inventory_transaction.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Inv/inventory_transaction失败: #{inventory_transaction.errors.full_messages.join(",")}")
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
          ::Inv::InventoryTransaction.transaction do
            selected_ids.each do |inventory_transaction_id|
              inventory_transaction = ::Inv::InventoryTransaction.find_by(id: inventory_transaction_id)
              if inventory_transaction
                if inventory_transaction.update(update_params)
                  results[:success] += 1
                  data << inventory_transaction
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Inv/inventory_transaction#{inventory_transaction.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: inventory_transaction_id, errors: inventory_transaction.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/inventory_transaction#{inventory_transaction.id}失败: #{inventory_transaction.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: inventory_transaction_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/inventory_transaction失败: 记录ID #{inventory_transaction_id} 不存在")
              end
            end
          end
        when "delete"
          ::Inv::InventoryTransaction.transaction do
            params[:ids].each do |inventory_transaction_id|
              inventory_transaction = ::Inv::InventoryTransaction.find(inventory_transaction_id)
              if inventory_transaction
                inventory_transaction.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Inv/inventory_transaction#{inventory_transaction.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: inventory_transaction_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Inv/inventory_transaction失败: 记录ID #{inventory_transaction_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_inventory_transaction
          @inventory_transaction = ::Inv::InventoryTransaction.find(params[:id]) rescue nil
          if @inventory_transaction.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def inventory_transaction_params
          params.permit(:code, :item_id, :location_id, :inventory_id, :transaction_type, :related_order_type, :related_order_id, :quantity_before, :quantity_change, :quantity_after, :operator_id, :transaction_time, :remark, :user_id, :updater_id)
        end

        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end

        def check_authorize
          begin
            authorize!(params[:action].to_sym, @inventory_transaction || ::Inv::InventoryTransaction)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
