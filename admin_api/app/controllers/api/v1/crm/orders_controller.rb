# frozen_string_literal: true

module Api
  module V1
    class Crm::OrdersController < BaseController
      before_action :set_order, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Crm/orders列表")

        begin
          query = ::Crm::Order.includes(:client, :follower, :status_property, order_lines: [:product, { file_attachment: :blob }])
        rescue StandardError
          query = ::Crm::Order.includes(:client, :follower, :status_property, :order_lines)
        end

        @q = query.ransack(params[:q])
        @orders = @q.result
        @orders = @orders.order(id: :desc) if ransack_sort_blank?(params[:q])

        page_num = params[:page] || params[:current] || 1
        per_page_num = params[:per_page] || params[:size] || per_page
        @orders = @orders.paginate(page: page_num, per_page: per_page_num)

        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @orders.map do |e|
            info = e.respond_to?(:base_info) ? e.base_info : e.attributes
            info.merge(
              line_items: e.order_lines.order(:id).map { |line| line.base_info }
            )
          end,
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def show
        log_crm_order_access(@order)

        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: {
            **@order.base_info,
            line_items: @order.order_lines.order(:id).map(&:base_info)
          }
        }
      end

      def create
        @order = ::Crm::Order.new(order_params)
        @order.user_id ||= @current_user.id
        @order.follower_id ||= @current_user.id
        if @order.save
          upsert_order_lines(@order, params[:line_items])

          # 来自预购单的新建订单：自动回写预购单状态
          if @order.pre_order_id.present?
            pre = ::Mat::PreOrder.find_by(id: @order.pre_order_id)
            pre&.update(
              status: ::Mat::PreOrder::STATUS_CONVERTED,
              crm_order_id: @order.id,
              processor_id: @current_user.id,
              processed_at: Time.current
            )
          end

          render json: {
            code: 200,
            success: 1,
            msg: t('create_success'),
            data: {
              **@order.reload.base_info,
              line_items: @order.order_lines.order(:id).map(&:base_info)
            }
          }
        else
          render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(','), data: '' }
        end
      end

      def update
        if params[:file].present?
          @order.file.attach(params[:file])
        end
        attrs = order_params.to_h
        attrs[:updater_id] = @current_user.id if @order.respond_to?(:updater_id=)
        if @order.update(attrs)
          if params.key?(:line_items)
            @order.order_lines.destroy_all
            upsert_order_lines(@order, params[:line_items])
          end
          render json: { code: 200, success: 1, msg: 'ok', data: @order.reload.base_info }
        else
          render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(','), data: '' }
        end
      end

      def destroy
        @order.destroy
        render json: { code: 200, success: 1, msg: 'success', data: '' }
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: '请指定操作类型(actions)', data: '' } if params[:actions].blank?

        action = params[:actions]
        return render json: { code: 500, success: 0, msg: '仅支持 delete', data: '' } unless action == 'delete'

        ids = params[:ids] || []
        ::Crm::Order.where(id: ids).destroy_all
        render json: { code: 200, success: 1, msg: '批量删除成功', data: '' }
      end

      private

      # 未指定 Ransack 排序时按 id 倒序；指定 q[s] 时由 Ransack 负责 ORDER BY
      def ransack_sort_blank?(q)
        return true if q.blank?

        s =
          if q.is_a?(ActionController::Parameters)
            q[:s].presence || q["s"].presence
          elsif q.is_a?(Hash)
            q[:s].presence || q["s"].presence
          end
        s.blank?
      end

      def set_order
        @order = ::Crm::Order.includes(:client, :follower, :status_property, order_lines: [:product, { file_attachment: :blob }]).find_by(id: params[:id])
        return if @order.present?

        render json: { code: 500, success: 0, msg: '记录不存在！', data: params[:action] }
      end

      def order_params
        params.permit(
          :pre_order_id,
          :client_id,
          :code,
          :hazard_pack_month,
          :receive_date,
          :contract_code,
          :customer_delivery_date,
          :follower_id,
          :follow_at,
          :follow_progress,
          :amount,
          :status_id,
          :delivered_qty,
          :invoice_amount,
          :invoice_at,
          :payment_amount,
          :payment_at,
          :user_id,
          :updater_id, 
          :spec_requirements
        )
      end

      def upsert_order_lines(order, raw_lines)
        lines = normalize_lines(raw_lines)
        lines.each_with_index do |line, idx|
          order.order_lines.create(
            product_id: line[:product_id],
            product_name: line[:product_name],
            model: line[:model],
            color: line[:color],
            weight: line[:weight],
            qty: line[:qty],
            unit: line[:unit],
            stock_status: line[:stock_status],
            color_master_status: line[:color_master_status],
            remark: line[:remark],
            sort: idx + 1,
            user_id: @current_user.id,
            unit_price: line[:unit_price],
            line_amount: line[:line_amount],
            ship_doc_unreturned: line[:ship_doc_unreturned],
            ship_doc_returned: line[:ship_doc_returned],
            delivery_qty: line[:delivery_qty],
            loss_qty: line[:loss_qty],
            line_delivery_date: line[:line_delivery_date],
            production_machine: line[:production_machine],
            injection_prod_code: line[:injection_prod_code],
            injection_prod_date: line[:injection_prod_date],
            gasket_machine: line[:gasket_machine],
            gasket_prod_code: line[:gasket_prod_code],
            gasket_prod_date: line[:gasket_prod_date],
            closing_date: line[:closing_date],
            semi_inventory: line[:semi_inventory],
            semi_completed: line[:semi_completed],
            semi_reserve: line[:semi_reserve],
            original_inventory: line[:original_inventory],
            outsourcing_qty: line[:outsourcing_qty],
            unfinished_qty: line[:unfinished_qty],
            finished_total: line[:finished_total]
          )
        end
      end

      def normalize_lines(raw_lines)
        return [] if raw_lines.blank?

        list =
          case raw_lines
          when Array then raw_lines
          when ActionController::Parameters then raw_lines.to_unsafe_h.values
          when Hash then raw_lines.values
          else []
          end

        list.map do |row|
          h = (row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row).to_h.symbolize_keys
          {
            product_id: h[:product_id],
            product_name: h[:product_name],
            model: h[:model],
            color: h[:color],
            weight: h[:weight],
            qty: h[:qty] || h[:quantity],
            unit: h[:unit],
            stock_status: h[:stock_status],
            color_master_status: h[:color_master_status],
            remark: h[:remark],
            unit_price: h[:unit_price],
            line_amount: h[:line_amount],
            ship_doc_unreturned: h[:ship_doc_unreturned],
            ship_doc_returned: h[:ship_doc_returned],
            delivery_qty: h[:delivery_qty],
            loss_qty: h[:loss_qty],
            line_delivery_date: h[:line_delivery_date],
            production_machine: h[:production_machine],
            injection_prod_code: h[:injection_prod_code],
            injection_prod_date: h[:injection_prod_date],
            gasket_machine: h[:gasket_machine],
            gasket_prod_code: h[:gasket_prod_code],
            gasket_prod_date: h[:gasket_prod_date],
            closing_date: h[:closing_date],
            semi_inventory: h[:semi_inventory],
            semi_completed: h[:semi_completed],
            semi_reserve: h[:semi_reserve],
            original_inventory: h[:original_inventory],
            outsourcing_qty: h[:outsourcing_qty],
            unfinished_qty: h[:unfinished_qty],
            finished_total: h[:finished_total]
          }
        end
      end

      def check_authorize
        authorize!(params[:action].to_sym, @order || ::Crm::Order)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: '没有权限访问', data: '' }, status: :forbidden
      end

      # 操作日志关联订单，供详情页「操作日志」筛选
      def log_crm_order_access(order)
        ::Log.create_log(
          10,
          @current_user.id,
          @current_ip,
          "访问订单详情 #{order.code}",
          params[:action].to_s,
          true,
          "Crm/订单",
          false,
          record_id: order.id,
          record_type: "Crm::Order"
        )
      rescue StandardError
        nil
      end
    end
  end
end
