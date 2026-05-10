# frozen_string_literal: true

module Api
  module V1
    class Wgd::OrdersController < BaseController
      before_action :set_order, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wgd/orders列表")

        query = ::Wgd::Order.includes(:client, :follower, :status_property, :order_lines)
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
            e.base_info.merge(line_items: e.order_lines.order(:sort, :id).map(&:base_info))
          end,
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def show
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @order.base_info.merge(line_items: @order.order_lines.order(:sort, :id).map(&:base_info))
        }
      end

      def create
        @order = ::Wgd::Order.new(order_params)
        @order.user_id ||= @current_user.id
        @order.follower_id ||= @current_user.id if @order.follower_id.blank? && @order.follower_name.blank?

        if @order.save
          upsert_order_lines(@order, params[:line_items])
          render json: {
            code: 200,
            success: 1,
            msg: t("create_success"),
            data: @order.reload.base_info.merge(line_items: @order.order_lines.order(:sort, :id).map(&:base_info))
          }
        else
          render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        attrs = order_params.to_h
        attrs[:updater_id] = @current_user.id if @order.respond_to?(:updater_id=)

        if @order.update(attrs)
          if params.key?(:line_items)
            @order.order_lines.destroy_all
            upsert_order_lines(@order, params[:line_items])
          end

          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @order.reload.base_info.merge(line_items: @order.order_lines.order(:sort, :id).map(&:base_info))
          }
        else
          render json: { code: 500, success: 0, msg: @order.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        @order.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?
        return render json: { code: 500, success: 0, msg: "仅支持 delete", data: "" } unless params[:actions] == "delete"

        ids = params[:ids] || []
        ::Wgd::Order.where(id: ids).destroy_all
        render json: { code: 200, success: 1, msg: "批量删除成功", data: "" }
      end

      private

      def set_order
        @order = ::Wgd::Order.includes(:client, :follower, :status_property, :order_lines).find_by(id: params[:id])
        return if @order.present?

        render json: { code: 500, success: 0, msg: "记录不存在！", data: params[:action] }
      end

      def order_params
        params.permit(
          :code,
          :receive_date,
          :client_id,
          :client_name,
          :contract_code,
          :hazard_pack_month,
          :customer_delivery_date_text,
          :follow_at,
          :follow_progress,
          :follower_id,
          :follower_name,
          :invoice_status,
          :invoice_at,
          :amount,
          :status_id,
          :remark,
          :user_id,
          :updater_id
        )
      end

      def upsert_order_lines(order, raw_lines)
        normalize_lines(raw_lines).each_with_index do |line, idx|
          order.order_lines.create(
            product_name: line[:product_name],
            model: line[:model],
            foil_pad_status: line[:foil_pad_status],
            color: line[:color],
            requirements: line[:requirements],
            weight: line[:weight],
            color_master_status: line[:color_master_status],
            product_image_text: line[:product_image_text],
            qty: line[:qty],
            unit: line[:unit],
            unit_price: line[:unit_price],
            line_amount: line[:line_amount],
            delivered_qty: line[:delivered_qty],
            undelivered_qty: line[:undelivered_qty],
            sort: line[:sort] || idx + 1,
            remark: line[:remark]
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
          (row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row).to_h.symbolize_keys
        end
      end

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

      def check_authorize
        authorize!(params[:action].to_sym, @order || ::Wgd::Order)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
  end
end
