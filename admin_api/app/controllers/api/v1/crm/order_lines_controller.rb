# frozen_string_literal: true

module Api
  module V1
    class Crm::OrderLinesController < BaseController
      before_action :set_order_line, only: [:show, :update, :destroy]
      before_action :check_authorize

      def internal_tracking
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问CRM内跟单")

        query = ::Crm::OrderLine
          .includes(:product, order: [:client, :status_property])
          .with_attached_file
        @q = query.ransack(params[:q])
        @order_lines = @q.result
        @order_lines = @order_lines.order(id: :desc) if ransack_sort_blank?(params[:q])

        page_num = params[:page] || params[:current] || 1
        per_page_num = params[:per_page] || params[:size] || per_page
        @order_lines = @order_lines.paginate(page: page_num, per_page: per_page_num)
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @order_lines.map(&:internal_tracking_row),
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def index
        query = ::Crm::OrderLine.order("id desc")
        @q = query.ransack(params[:q])
        @order_lines = @q.result

        page_num = params[:page] || params[:current] || 1
        per_page_num = params[:per_page] || params[:size] || per_page
        @order_lines = @order_lines.paginate(page: page_num, per_page: per_page_num)
        render json: {
          code: 200,
          success: 1,
          msg: 'ok',
          data: @order_lines.map(&:base_info),
          total: @q.result.size,
          size: per_page_num,
          page: page_num
        }
      end

      def show
        render json: { code: 200, success: 1, msg: 'ok', data: @order_line.base_info }
      end

      def create
        @order_line = ::Crm::OrderLine.new(order_line_params)
        @order_line.user_id ||= @current_user.id
        if @order_line.save
          render json: { code: 200, success: 1, msg: t('create_success'), data: @order_line.base_info }
        else
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(','), data: '' }
        end
      end

      def update
        if params[:file].present?
          @order_line.file.attach(params[:file])
        end
        permitted = order_line_params
        if permitted.respond_to?(:keys) && permitted.keys.any?
          @order_line.assign_attributes(permitted)
        end
        if @order_line.save
          render json: { code: 200, success: 1, msg: 'ok', data: @order_line.base_info }
        else
          render json: { code: 500, success: 0, msg: @order_line.errors.full_messages.join(','), data: '' }
        end
      end

      def destroy
        @order_line.destroy
        render json: { code: 200, success: 1, msg: 'success', data: '' }
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: '请指定操作类型(actions)', data: '' } if params[:actions].blank?

        return render json: { code: 500, success: 0, msg: '仅支持 delete', data: '' } unless params[:actions] == 'delete'

        ids = params[:ids] || []
        ::Crm::OrderLine.where(id: ids).destroy_all
        render json: { code: 200, success: 1, msg: '批量删除成功', data: '' }
      end

      private

      def set_order_line
        @order_line = ::Crm::OrderLine.find_by(id: params[:id])
        return if @order_line.present?

        render json: { code: 500, success: 0, msg: '记录不存在！', data: params[:action] }
      end

      def order_line_params
        params.permit(
          :order_id,
          :product_id,
          :product_name,
          :model,
          :color,
          :weight,
          :qty,
          :unit,
          :stock_status,
          :color_master_status,
          :remark,
          :sort,
          :user_id,
          :unit_price,
          :line_amount,
          :ship_doc_unreturned,
          :ship_doc_returned,
          :delivery_qty,
          :loss_qty,
          :line_delivery_date,
          :production_machine,
          :injection_prod_code,
          :injection_prod_date,
          :gasket_machine,
          :gasket_prod_code,
          :gasket_prod_date,
          :closing_date,
          :semi_inventory,
          :semi_completed,
          :semi_reserve,
          :original_inventory,
          :outsourcing_qty,
          :unfinished_qty,
          :finished_total
        )
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
        authorize!(params[:action].to_sym, @order_line || ::Crm::OrderLine)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: '没有权限访问', data: '' }, status: :forbidden
      end
    end
  end
end
