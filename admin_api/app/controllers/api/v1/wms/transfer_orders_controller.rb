module Api
  module V1
    class Wms::TransferOrdersController < BaseController
      before_action :set_transfer_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/wms/transfer_orders
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wms/transfer_order列表")
        
        query = ::Wms::TransferOrder.order("id desc")
        
        begin
          associations = [:user, :updater, :transfer_order_lines]
          associations.select! { |assoc| ::Wms::TransferOrder.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        
        @q = query.ransack(params[:q])
        @transfer_orders = @q.result()
        
        if params[:list]
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @transfer_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @transfer_orders.size, 
            size: per_page, 
            page: page 
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @transfer_orders = @transfer_orders.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @transfer_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@transfer_order) ? @transfer_order.base_info : @transfer_order.attributes 
        }
      end

      def create
        @transfer_order = ::Wms::TransferOrder.new(transfer_order_params)
        @transfer_order.user_id = @current_user.id if @transfer_order.respond_to?(:user_id) && @transfer_order.user_id.nil?

        ::Wms::TransferOrder.transaction do
          if @transfer_order.save
            # 创建关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                line = @transfer_order.transfer_order_lines.build(
                  item_id: line_params[:item_id],
                  from_location_id: line_params[:from_location_id],
                  to_location_id: line_params[:to_location_id],
                  plan_qty: line_params[:plan_qty],
                  moved_qty: line_params[:moved_qty] || 0,
                  received_qty: line_params[:received_qty] || 0
                )
                unless line.save
                  raise ActiveRecord::Rollback
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/transfer_order明细失败: #{line.errors.full_messages.join(",")}")
                  return render json: {
                    code: 500,
                    success: 0,
                    msg: "明细创建失败: #{line.errors.full_messages.join(",")}",
                    data: ""
                  }
                end
              end
            end

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Wms/transfer_order#{@transfer_order.code rescue @transfer_order.id}成功")
            render json: {
              code: 200, 
              success: 1, 
              msg: t('create_success'), 
              data: model_has_base_info?(@transfer_order) ? @transfer_order.base_info : @transfer_order.attributes 
            }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/transfer_order失败: #{@transfer_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @transfer_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def update
        transfer_order_params_hash = transfer_order_params.to_h
        transfer_order_params_hash[:updater_id] = @current_user.id if @transfer_order.respond_to?(:updater_id)

        ::Wms::TransferOrder.transaction do
          if @transfer_order.update(transfer_order_params_hash)
            # 更新关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              # 删除现有明细（如果需要完全替换）
              # @transfer_order.transfer_order_lines.destroy_all if params[:replace_lines] == true
              
              params[:lines].each do |line_params|
                if line_params[:id].present?
                  # 更新现有明细
                  line = @transfer_order.transfer_order_lines.find_by(id: line_params[:id])
                  if line
                    unless line.update(
                      item_id: line_params[:item_id],
                      from_location_id: line_params[:from_location_id],
                      to_location_id: line_params[:to_location_id],
                      plan_qty: line_params[:plan_qty],
                      moved_qty: line_params[:moved_qty],
                      received_qty: line_params[:received_qty]
                    )
                      raise ActiveRecord::Rollback
                      return render json: {
                        code: 500,
                        success: 0,
                        msg: "明细更新失败: #{line.errors.full_messages.join(",")}",
                        data: ""
                      }
                    end
                  end
                else
                  # 创建新明细
                  line = @transfer_order.transfer_order_lines.build(
                    item_id: line_params[:item_id],
                    from_location_id: line_params[:from_location_id],
                    to_location_id: line_params[:to_location_id],
                    plan_qty: line_params[:plan_qty],
                    moved_qty: line_params[:moved_qty] || 0,
                    received_qty: line_params[:received_qty] || 0
                  )
                  unless line.save
                    raise ActiveRecord::Rollback
                    return render json: {
                      code: 500,
                      success: 0,
                      msg: "明细创建失败: #{line.errors.full_messages.join(",")}",
                      data: ""
                    }
                  end
                end
              end
            end

            render json: {
              code: 200, 
              success: 1, 
              msg: "ok", 
              data: model_has_base_info?(@transfer_order) ? @transfer_order.base_info : @transfer_order.attributes 
            }
            gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/transfer_order修改#{@transfer_order.code rescue @transfer_order.id} 成功")
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "Wms/transfer_order修改#{@transfer_order.code rescue @transfer_order.id} 失败: #{@transfer_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @transfer_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/transfer_order删除#{@transfer_order.code rescue @transfer_order.id}成功")
        @transfer_order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Wms::TransferOrder.respond_to?(:imp_exp_hander) ? ::Wms::TransferOrder.imp_exp_hander : ::Wms::TransferOrder.column_names
          i18n_column_names = ::Wms::TransferOrder.respond_to?(:il8n_imp_exp_hander) ? ::Wms::TransferOrder.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Wms/transfer_order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Wms::TransferOrder.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Wms/transfer_order预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:transfer_orders].blank?

          ::Wms::TransferOrder.transaction do
            params[:transfer_orders].each do |transfer_order_params|
              transfer_order = ::Wms::TransferOrder.new(transfer_order_params.to_unsafe_h)
              if transfer_order.save
                results[:success] += 1
                data << transfer_order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Wms/transfer_order#{transfer_order.code rescue transfer_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: transfer_order_params, errors: transfer_order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Wms/transfer_order#{transfer_order_params[:code]}失败: #{transfer_order.errors.full_messages.join(",")}")
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

          ::Wms::TransferOrder.transaction do
            selected_ids.each do |transfer_order_id|
              transfer_order = ::Wms::TransferOrder.find_by(id: transfer_order_id)
              if transfer_order
                if transfer_order.update(update_params)
                  results[:success] += 1
                  data << transfer_order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Wms/transfer_order#{transfer_order.code rescue transfer_order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: transfer_order_id, errors: transfer_order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/transfer_order#{transfer_order.code rescue transfer_order.id}失败: #{transfer_order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: transfer_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/transfer_order失败: 记录ID #{transfer_order_id} 不存在")
              end
            end
          end

        when "delete"
          ::Wms::TransferOrder.transaction do
            params[:ids].each do |transfer_order_id|
              transfer_order = ::Wms::TransferOrder.find(transfer_order_id)
              if transfer_order
                transfer_order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Wms/transfer_order#{transfer_order.code rescue transfer_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: transfer_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Wms/transfer_order失败: 记录ID #{transfer_order_id} 不存在")
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
        def set_transfer_order
          @transfer_order = ::Wms::TransferOrder.find(params[:id]) rescue nil
          if @transfer_order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def transfer_order_params
          params.permit(:code, :transfer_type, :status, :from_warehouse_id, :to_warehouse_id, :move_category, :plan_date, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @transfer_order || ::Wms::TransferOrder)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
