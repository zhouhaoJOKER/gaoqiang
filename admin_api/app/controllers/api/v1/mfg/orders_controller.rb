module Api
  module V1
    class Mfg::OrdersController < BaseController
      before_action :set_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/order列表")
        query = ::Mfg::Order.order("id desc")
        begin
          associations = [:company, :user, :updater, :product, :item, :bom, :order_lines]
          associations.select! { |assoc| ::Mfg::Order.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @orders = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @orders.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @orders = @orders.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @orders.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@order) ? @order.base_info : @order.attributes }
      end

      def create
        @order = ::Mfg::Order.new(order_params)
        @order.user_id = @current_user.id if @order.respond_to?(:user_id) && @order.user_id.nil?

        ::Mfg::Order.transaction do
          if @order.save
            # 创建关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                line = @order.order_lines.build(
                  product_id: line_params[:product_id],
                  item_id: line_params[:item_id],
                  bom_line_id: line_params[:bom_line_id],
                  required_date: line_params[:required_date],
                  required_qty: line_params[:required_qty],
                  allocated_qty: line_params[:allocated_qty] || 0,
                  available_qty: line_params[:available_qty] || 0,
                  shortage_qty: line_params[:shortage_qty] || 0,
                  status: line_params[:status],
                  is_alternative: line_params[:is_alternative] || false,
                  alternative_for_id: line_params[:alternative_for_id]
                )
                unless line.save
                  raise ActiveRecord::Rollback
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/order明细失败: #{line.errors.full_messages.join(",")}")
                  return render json: {
                    code: 500,
                    success: 0,
                    msg: "明细创建失败: #{line.errors.full_messages.join(",")}",
                    data: ""
                  }
                end
              end
            end

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/order#{@order.code rescue @order.id}成功")
            render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@order) ? @order.base_info : @order.attributes }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/order失败: #{@order.errors.full_messages.join(",")}")
            render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(","), data: "" }
          end
        end
      end

      def update
        order_params_hash = order_params.to_h
        order_params_hash[:updater_id] = @current_user.id if @order.respond_to?(:updater_id)

        ::Mfg::Order.transaction do
          if @order.update(order_params_hash)
            # 更新关联的明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                if line_params[:id].present?
                  line = @order.order_lines.find_by(id: line_params[:id])
                  if line
                    unless line.update(
                      product_id: line_params[:product_id],
                      item_id: line_params[:item_id],
                      bom_line_id: line_params[:bom_line_id],
                      required_date: line_params[:required_date],
                      required_qty: line_params[:required_qty],
                      allocated_qty: line_params[:allocated_qty],
                      available_qty: line_params[:available_qty],
                      shortage_qty: line_params[:shortage_qty],
                      status: line_params[:status],
                      is_alternative: line_params[:is_alternative],
                      alternative_for_id: line_params[:alternative_for_id]
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
                  line = @order.order_lines.build(
                    product_id: line_params[:product_id],
                    item_id: line_params[:item_id],
                    bom_line_id: line_params[:bom_line_id],
                    required_date: line_params[:required_date],
                    required_qty: line_params[:required_qty],
                    allocated_qty: line_params[:allocated_qty] || 0,
                    available_qty: line_params[:available_qty] || 0,
                    shortage_qty: line_params[:shortage_qty] || 0,
                    status: line_params[:status],
                    is_alternative: line_params[:is_alternative] || false,
                    alternative_for_id: line_params[:alternative_for_id]
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

            render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@order) ? @order.base_info : @order.attributes }
            gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/order修改#{@order.code rescue @order.id} 成功")
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/order修改#{@order.code rescue @order.id} 失败: #{@order.errors.full_messages.join(",")}")
            render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(","), data: "" }
          end
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/order删除#{@order.code rescue @order.id}成功")
        @order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::Order.respond_to?(:imp_exp_hander) ? ::Mfg::Order.imp_exp_hander : ::Mfg::Order.column_names
          i18n_column_names = ::Mfg::Order.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::Order.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/order模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::Order.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/order预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:orders].blank?
          ::Mfg::Order.transaction do
            params[:orders].each do |order_params|
              order = ::Mfg::Order.new(order_params.to_unsafe_h)
              if order.save
                results[:success] += 1
                data << order
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/order#{order.code rescue order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: order_params, errors: order.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/order#{order_params[:code]}失败: #{order.errors.full_messages.join(",")}")
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
          ::Mfg::Order.transaction do
            selected_ids.each do |order_id|
              order = ::Mfg::Order.find_by(id: order_id)
              if order
                if order.update(update_params)
                  results[:success] += 1
                  data << order
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/order#{order.code rescue order.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: order_id, errors: order.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/order#{order.code rescue order.id}失败: #{order.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/order失败: 记录ID #{order_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::Order.transaction do
            params[:ids].each do |order_id|
              order = ::Mfg::Order.find(order_id)
              if order
                order.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/order#{order.code rescue order.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: order_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/order失败: 记录ID #{order_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_order
          @order = ::Mfg::Order.find(params[:id]) rescue nil
          if @order.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def order_params
          params.permit(:code, :product_id, :item_id, :bom_id, :plan_qty, :finish_qty, :scrap_qty, :status, :demand_date, :source_order_type, :source_order_id, :company_id, :warehouse_id, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @order || ::Mfg::Order)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
