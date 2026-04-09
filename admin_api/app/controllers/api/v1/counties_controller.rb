# frozen_string_literal: true

module Api
  module V1
    class CountiesController < BaseController
      before_action :set_county, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/counties
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问县区列表")
        query = County.order(:code)
        query = query.where(city_id: params[:city_id]) if params[:city_id].present?
        @q = query.ransack(params[:q])
        @counties = @q.result
        if params[:list]
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @counties.map(&:attributes),
            total: @counties.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @counties = @counties.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @counties.map(&:attributes),
            total: @q.result.size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/counties/:id
      def show
        render json: { code: 200, success: 1, msg: "ok", data: @county.attributes }
      end

      # POST /api/v1/counties
      def create
        @county = County.new(county_params)
        if @county.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加县区#{@county.name}成功")
          render json: { code: 200, success: 1, msg: t("create_success"), data: @county.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加县区失败: #{@county.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @county.errors.full_messages.join(","), data: "" }
        end
      end

      # PUT /api/v1/counties/:id
      def update
        if @county.update(county_params)
          gen_log(@current_user.id, @current_ip, params[:action], 1, "修改县区#{@county.name}成功")
          render json: { code: 200, success: 1, msg: "ok", data: @county.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "修改县区失败: #{@county.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @county.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/counties/:id
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "删除县区#{@county.name}成功")
        @county.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      private

      def set_county
        @county = County.find(params[:id]) rescue nil
        if @county.nil?
          gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]} 记录不存在")
          render json: { code: 500, success: 0, msg: "记录不存在！", data: "" }
        end
      end

      def county_params
        params.permit(:city_id, :code, :name, :py)
      end

      def check_authorize
        authorize!(params[:action].to_sym, @county || County)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
  end
end
