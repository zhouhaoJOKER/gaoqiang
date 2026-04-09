# frozen_string_literal: true

module Api
  module V1
    class Crm::PreOrdersController < BaseController
      before_action :set_pre_order, only: [:show, :update, :destroy, :convert_to_order]
      before_action :check_authorize

      def index
        query = ::Mat::PreOrder.order("id desc")

        # 状态：默认仅待处理；status_scope=all 时不过滤状态
        status_scope = params[:status_scope].presence || "pending"
        unless status_scope == "all"
          query = query.where(status: status_scope)
        end

        # 关键词：客户名称、编号（模糊）
        keyword = params[:keyword].to_s.strip
        if keyword.present?
          like = "%#{ActiveRecord::Base.sanitize_sql_like(keyword)}%"
          query = query.where(
            "customer_name LIKE ? OR IFNULL(customer_code,'') LIKE ?",
            like,
            like
          )
        end

        @q = query.ransack(params[:q])
        @pre_orders = @q.result

        page_num = params[:page] || params[:current] || 1
        per_page_num = params[:per_page] || params[:size] || per_page
        @pre_orders = @pre_orders.paginate(page: page_num, per_page: per_page_num)

        render json: {
          code: 200,
          success: 1,
          msg: 'ok',
          data: @pre_orders.map(&:base_info),
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def show
        render json: { code: 200, success: 1, msg: 'ok', data: @pre_order.base_info }
      end

      def update
        if @pre_order.update(pre_order_params.merge(processor_id: @current_user.id))
          render json: { code: 200, success: 1, msg: 'ok', data: @pre_order.base_info }
        else
          render json: { code: 500, success: 0, msg: @pre_order.errors.full_messages.join(','), data: '' }
        end
      end

      def destroy
        @pre_order.destroy
        render json: { code: 200, success: 1, msg: 'success', data: '' }
      end

      # POST /api/v1/crm/pre_orders/:id/convert_to_order
      def convert_to_order
        if @pre_order.crm_order_id.present?
          return render json: {
            code: 500,
            success: 0,
            msg: '该预购单已转换订单',
            data: @pre_order.base_info
          }
        end

        client_id = params[:client_id].presence
        return render json: { code: 500, success: 0, msg: '请选择客户(client_id)', data: '' } if client_id.blank?

        order = nil
        ::Crm::Order.transaction do
          order = ::Crm::Order.create!(
            pre_order_id: @pre_order.id,
            client_id: client_id,
            receive_date: params[:receive_date].presence || Date.current,
            contract_code: params[:contract_code],
            customer_delivery_date: params[:customer_delivery_date],
            follower_id: params[:follower_id].presence || @current_user.id,
            follow_at: params[:follow_at],
            follow_progress: params[:follow_progress],
            amount: params[:amount].presence || 0,
            status_id: params[:status_id].presence,
            delivered_qty: params[:delivered_qty].presence || 0,
            invoice_amount: params[:invoice_amount].presence || 0,
            invoice_at: params[:invoice_at],
            payment_amount: params[:payment_amount].presence || 0,
            payment_at: params[:payment_at],
            user_id: @current_user.id,
            updater_id: @current_user.id
          )

          normalize_lines(@pre_order.line_items).each_with_index do |line, idx|
            order.order_lines.create!(
              product_id: line[:product_id],
              product_name: line[:product_name],
              model: line[:model],
              color: line[:color],
              weight: line[:weight],
              qty: line[:quantity],
              unit: line[:unit],
              stock_status: line[:stock_status],
              color_master_status: line[:color_master_status],
              remark: line[:remark],
              sort: idx + 1,
              user_id: @current_user.id
            )
          end

          @pre_order.update!(
            status: ::Mat::PreOrder::STATUS_CONVERTED,
            crm_order_id: order.id,
            processor_id: @current_user.id,
            processed_at: Time.current
          )
        end

        render json: {
          code: 200,
          success: 1,
          msg: '转换成功',
          data: {
            pre_order: @pre_order.base_info,
            crm_order: order.base_info
          }
        }
      rescue StandardError => e
        render json: { code: 500, success: 0, msg: "转换失败: #{e.message}", data: '' }
      end

      private

      def set_pre_order
        @pre_order = ::Mat::PreOrder.find_by(id: params[:id])
        return if @pre_order.present?

        render json: { code: 500, success: 0, msg: '记录不存在！', data: params[:action] }
      end

      def pre_order_params
        params.permit(:status, :processed_at)
      end

      def normalize_lines(lines)
        return [] unless lines.is_a?(Array)

        lines.map do |row|
          h = row.to_h.symbolize_keys
          {
            product_id: h[:product_id],
            product_name: h[:product_name],
            model: h[:model],
            color: h[:color],
            weight: h[:weight],
            quantity: h[:quantity] || h[:qty],
            unit: h[:unit],
            stock_status: h[:stock_status],
            color_master_status: h[:color_master_status],
            remark: h[:remark]
          }
        end
      end

      def check_authorize
        authorize!(params[:action].to_sym, @pre_order || ::Mat::PreOrder)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: '没有权限访问', data: '' }, status: :forbidden
      end
    end
  end
end
