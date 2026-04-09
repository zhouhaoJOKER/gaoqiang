module Api
  module V1
    class Wms::PickOrdersController < BaseController
      before_action :set_pick_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/wms/pick_orders
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wms/pick_order列表")
        
        query = ::Wms::PickOrder.order("id desc")
        
        begin
          associations = [:company, :user, :updater, :pick_order_lines]
          associations.select! { |assoc| ::Wms::PickOrder.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        
        @q = query.ransack(params[:q])
        @pick_orders = @q.result()
        
        if params[:list]
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @pick_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @pick_orders.size, 
            size: per_page, 
            page: page 
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @pick_orders = @pick_orders.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @pick_orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
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
          data: model_has_base_info?(@pick_order) ? @pick_order.base_info : @pick_order.attributes 
        }
      end

      def create
        @pick_order = ::Wms::PickOrder.new(pick_order_params)
        @pick_order.user_id = @current_user.id if @pick_order.respond_to?(:user_id) && @pick_order.user_id.nil?

        ::Wms::PickOrder.transaction do
          if @pick_order.save
            # 创建关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                line = @pick_order.pick_order_lines.build(
                  item_id: line_params[:item_id],
                  location_id: line_params[:location_id],
                  plan_qty: line_params[:plan_qty],
                  picked_qty: line_params[:picked_qty] || 0,
                  status: line_params[:status],
                  user_id: @current_user.id
                )
                unless line.save
                  raise ActiveRecord::Rollback
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/pick_order明细失败: #{line.errors.full_messages.join(",")}")
                  return render json: {
                    code: 500,
                    success: 0,
                    msg: "明细创建失败: #{line.errors.full_messages.join(",")}",
                    data: ""
                  }
                end
              end
            end

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Wms/pick_order#{@pick_order.code rescue @pick_order.id}成功")
            render json: {
              code: 200, 
              success: 1, 
              msg: t('create_success'), 
              data: model_has_base_info?(@pick_order) ? @pick_order.base_info : @pick_order.attributes 
            }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/pick_order失败: #{@pick_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @pick_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def update
        pick_order_params_hash = pick_order_params.to_h
        pick_order_params_hash[:updater_id] = @current_user.id if @pick_order.respond_to?(:updater_id)

        ::Wms::PickOrder.transaction do
          if @pick_order.update(pick_order_params_hash)
            # 更新关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                if line_params[:id].present?
                  line = @pick_order.pick_order_lines.find_by(id: line_params[:id])
                  if line
                    unless line.update(
                      item_id: line_params[:item_id],
                      location_id: line_params[:location_id],
                      plan_qty: line_params[:plan_qty],
                      picked_qty: line_params[:picked_qty],
                      status: line_params[:status],
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
                  line = @pick_order.pick_order_lines.build(
                    item_id: line_params[:item_id],
                    location_id: line_params[:location_id],
                    plan_qty: line_params[:plan_qty],
                    picked_qty: line_params[:picked_qty] || 0,
                    status: line_params[:status],
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
              data: model_has_base_info?(@pick_order) ? @pick_order.base_info : @pick_order.attributes 
            }
            gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/pick_order修改#{@pick_order.code rescue @pick_order.id} 成功")
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "Wms/pick_order修改#{@pick_order.code rescue @pick_order.id} 失败: #{@pick_order.errors.full_messages.join(",")}")
            render json: {
              code: 500, 
              success: 0, 
              msg: @pick_order.errors.full_messages.join(","), 
              data: "" 
            }
          end
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/pick_order删除#{@pick_order.code rescue @pick_order.id}成功")
        @pick_order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Wms::PickOrder.respond_to?(:imp_exp_hander) ? ::Wms::PickOrder.imp_exp_hander : ::Wms::PickOrder.column_names
          i18n_column_names = ::Wms::PickOrder.respond_to?(:il8n_imp_exp_hander) ? ::Wms::PickOrder.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Wms/pick_order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Wms::PickOrder.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Wms/pick_order预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:pick_orders].blank?

          ::Wms::PickOrder.transaction do
            params[:pick_orders].each do |pick_order_params|
              pick_order = ::Wms::PickOrder.new(pick_order_params.to_unsafe_h)
              if pick_order.save
                results[:success] += 1
                data << pick_order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Wms/pick_order#{pick_order.code rescue pick_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: pick_order_params, errors: pick_order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Wms/pick_order#{pick_order_params[:code]}失败: #{pick_order.errors.full_messages.join(",")}")
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

          ::Wms::PickOrder.transaction do
            selected_ids.each do |pick_order_id|
              pick_order = ::Wms::PickOrder.find_by(id: pick_order_id)
              if pick_order
                if pick_order.update(update_params)
                  results[:success] += 1
                  data << pick_order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Wms/pick_order#{pick_order.code rescue pick_order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: pick_order_id, errors: pick_order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/pick_order#{pick_order.code rescue pick_order.id}失败: #{pick_order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: pick_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/pick_order失败: 记录ID #{pick_order_id} 不存在")
              end
            end
          end

        when "delete"
          ::Wms::PickOrder.transaction do
            params[:ids].each do |pick_order_id|
              pick_order = ::Wms::PickOrder.find(pick_order_id)
              if pick_order
                pick_order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Wms/pick_order#{pick_order.code rescue pick_order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: pick_order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Wms/pick_order失败: 记录ID #{pick_order_id} 不存在")
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
        def set_pick_order
          @pick_order = ::Wms::PickOrder.find(params[:id]) rescue nil
          if @pick_order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def pick_order_params
          params.permit(:code, :work_order_id, :order_category, :status, :warehouse_id, :plan_date, :company_id, :description, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @pick_order || ::Wms::PickOrder)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
