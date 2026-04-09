module Api
  module V1
    class Wms::ReturnOrdersController < BaseController
      before_action :set_return_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/wms/return_orders
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wms/return_order列表")
        
        query = ::Wms::ReturnOrder.order("id desc")
        
        begin
          associations = [:user, :updater, :return_order_lines]
          associations.select! { |assoc| ::Wms::ReturnOrder.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        
        @q = query.ransack(params[:q])
        @return_orders = @q.result()
        
        if params[:list]
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @return_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @return_orders.size, 
            size: per_page, 
            page: page 
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @return_orders = @return_orders.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @return_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
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
          data: model_has_base_info?(@return_order) ? @return_order.base_info : @return_order.attributes 
        }
      end

      def create
        @return_order = ::Wms::ReturnOrder.new(return_order_params)
        @return_order.user_id = @current_user.id if @return_order.respond_to?(:user_id) && @return_order.user_id.nil?

        ::Wms::ReturnOrder.transaction do
          if @return_order.save
            # 创建关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                line = @return_order.return_order_lines.build(
                  item_id: line_params[:item_id],
                  location_id: line_params[:location_id],
                  returned_qty: line_params[:returned_qty],
                  damage_status: line_params[:damage_status],
                  inventory_status_id: line_params[:inventory_status_id],
                  user_id: @current_user.id
                )
                unless line.save
                  raise ActiveRecord::Rollback
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/return_order明细失败: #{line.errors.full_messages.join(",")}")
                  return render json: {
                    code: 500,
                    success: 0,
                    msg: "明细创建失败: #{line.errors.full_messages.join(",")}",
                    data: ""
                  }
                end
              end
            end

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Wms/return_order#{@return_order.code rescue @return_order.id}成功")
            render json: {
              code: 200, 
              success: 1, 
              msg: t('create_success'), 
              data: model_has_base_info?(@return_order) ? @return_order.base_info : @return_order.attributes 
            }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/return_order失败: #{@return_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @return_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def update
        return_order_params_hash = return_order_params.to_h
        return_order_params_hash[:updater_id] = @current_user.id if @return_order.respond_to?(:updater_id)

        ::Wms::ReturnOrder.transaction do
          if @return_order.update(return_order_params_hash)
            # 更新关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                if line_params[:id].present?
                  line = @return_order.return_order_lines.find_by(id: line_params[:id])
                  if line
                    unless line.update(
                      item_id: line_params[:item_id],
                      location_id: line_params[:location_id],
                      returned_qty: line_params[:returned_qty],
                      damage_status: line_params[:damage_status],
                      inventory_status_id: line_params[:inventory_status_id],
                      updater_id: @current_user.id
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
                  line = @return_order.return_order_lines.build(
                    item_id: line_params[:item_id],
                    location_id: line_params[:location_id],
                    returned_qty: line_params[:returned_qty],
                    damage_status: line_params[:damage_status],
                    inventory_status_id: line_params[:inventory_status_id],
                    user_id: @current_user.id
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
              data: model_has_base_info?(@return_order) ? @return_order.base_info : @return_order.attributes 
            }
            gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/return_order修改#{@return_order.code rescue @return_order.id} 成功")
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "Wms/return_order修改#{@return_order.code rescue @return_order.id} 失败: #{@return_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @return_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/return_order删除#{@return_order.code rescue @return_order.id}成功")
        @return_order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Wms::ReturnOrder.respond_to?(:imp_exp_hander) ? ::Wms::ReturnOrder.imp_exp_hander : ::Wms::ReturnOrder.column_names
          i18n_column_names = ::Wms::ReturnOrder.respond_to?(:il8n_imp_exp_hander) ? ::Wms::ReturnOrder.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Wms/return_order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Wms::ReturnOrder.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Wms/return_order预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:return_orders].blank?

          ::Wms::ReturnOrder.transaction do
            params[:return_orders].each do |return_order_params|
              return_order = ::Wms::ReturnOrder.new(return_order_params.to_unsafe_h)
              if return_order.save
                results[:success] += 1
                data << return_order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Wms/return_order#{return_order.code rescue return_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: return_order_params, errors: return_order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Wms/return_order#{return_order_params[:code]}失败: #{return_order.errors.full_messages.join(",")}")
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

          ::Wms::ReturnOrder.transaction do
            selected_ids.each do |return_order_id|
              return_order = ::Wms::ReturnOrder.find_by(id: return_order_id)
              if return_order
                if return_order.update(update_params)
                  results[:success] += 1
                  data << return_order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Wms/return_order#{return_order.code rescue return_order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: return_order_id, errors: return_order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/return_order#{return_order.code rescue return_order.id}失败: #{return_order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: return_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/return_order失败: 记录ID #{return_order_id} 不存在")
              end
            end
          end

        when "delete"
          ::Wms::ReturnOrder.transaction do
            params[:ids].each do |return_order_id|
              return_order = ::Wms::ReturnOrder.find(return_order_id)
              if return_order
                return_order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Wms/return_order#{return_order.code rescue return_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: return_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Wms/return_order失败: 记录ID #{return_order_id} 不存在")
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
        def set_return_order
          @return_order = ::Wms::ReturnOrder.find(params[:id]) rescue nil
          if @return_order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def return_order_params
          params.permit(:code, :return_category, :status, :original_order_id, :warehouse_id, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @return_order || ::Wms::ReturnOrder)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
