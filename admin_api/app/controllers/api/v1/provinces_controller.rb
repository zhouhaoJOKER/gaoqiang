# frozen_string_literal: true

module Api
  module V1
    class ProvincesController < BaseController
      before_action :set_province, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/provinces
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问省列表")
        query = Province.order(:code)
        @q = query.ransack(params[:q])
        @provinces = @q.result
        if params[:list]
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @provinces.map(&:attributes),
            total: @provinces.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @provinces = @provinces.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @provinces.map(&:attributes),
            total: @q.result.size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/provinces/:id
      def show
        render json: { code: 200, success: 1, msg: "ok", data: @province.attributes }
      end

      # POST /api/v1/provinces
      def create
        @province = Province.new(province_params)
        if @province.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加省#{@province.name}成功")
          render json: { code: 200, success: 1, msg: t("create_success"), data: @province.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加省失败: #{@province.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @province.errors.full_messages.join(","), data: "" }
        end
      end

      # PUT /api/v1/provinces/:id
      def update
        if @province.update(province_params)
          gen_log(@current_user.id, @current_ip, params[:action], 1, "修改省#{@province.name}成功")
          render json: { code: 200, success: 1, msg: "ok", data: @province.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "修改省失败: #{@province.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @province.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/provinces/:id
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "删除省#{@province.name}成功")
        @province.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      private

      def set_province
        @province = Province.find(params[:id]) rescue nil
        if @province.nil?
          gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]} 记录不存在")
          render json: { code: 500, success: 0, msg: "记录不存在！", data: "" }
        end
      end

      def province_params
        params.permit(:code, :name, :py)
      end

      def check_authorize
        authorize!(params[:action].to_sym, @province || Province)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
  end
end
