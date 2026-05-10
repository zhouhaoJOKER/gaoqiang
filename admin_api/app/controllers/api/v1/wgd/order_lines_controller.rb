# frozen_string_literal: true

module Api
  module V1
    class Wgd::OrderLinesController < BaseController
      before_action :set_order_line, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      def index
        query = ::Wgd::OrderLine.includes(:order).order(id: :desc)
        @q = query.ransack(params[:q])
        @order_lines = @q.result

        page_num = params[:page] || params[:current] || 1
        per_page_num = params[:per_page] || params[:size] || per_page
        @order_lines = @order_lines.paginate(page: page_num, per_page: per_page_num)

        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @order_lines.map(&:base_info),
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: @order_line.base_info }
      end

      def create
        @order_line = ::Wgd::OrderLine.new(order_line_params)
        if @order_line.save
          render json: { code: 200, success: 1, msg: t("create_success"), data: @order_line.base_info }
        else
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        if @order_line.update(order_line_params)
          render json: { code: 200, success: 1, msg: "ok", data: @order_line.base_info }
        else
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        @order_line.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?
        return render json: { code: 500, success: 0, msg: "仅支持 delete", data: "" } unless params[:actions] == "delete"

        ids = params[:ids] || []
        ::Wgd::OrderLine.where(id: ids).destroy_all
        render json: { code: 200, success: 1, msg: "批量删除成功", data: "" }
      end

      private

      def set_order_line
        @order_line = ::Wgd::OrderLine.find_by(id: params[:id])
        return if @order_line.present?

        render json: { code: 500, success: 0, msg: "记录不存在！", data: params[:action] }
      end

      def order_line_params
        params.permit(
          :order_id,
          :product_name,
          :model,
          :foil_pad_status,
          :color,
          :requirements,
          :weight,
          :color_master_status,
          :product_image_text,
          :qty,
          :unit,
          :unit_price,
          :line_amount,
          :delivered_qty,
          :undelivered_qty,
          :sort,
          :remark
        )
      end

      def check_authorize
        authorize!(params[:action].to_sym, @order_line || ::Wgd::OrderLine)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
  end
end
