# frozen_string_literal: true

module Api
  module V1
    class CitiesController < BaseController
      before_action :set_city, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/cities
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问市列表")
        query = City.order(:code)
        query = query.where(province_id: params[:province_id]) if params[:province_id].present?
        @q = query.ransack(params[:q])
        @cities = @q.result
        if params[:list]
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @cities.map(&:attributes),
            total: @cities.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @cities = @cities.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @cities.map(&:attributes),
            total: @q.result.size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/cities/:id
      def show
        render json: { code: 200, success: 1, msg: "ok", data: @city.attributes }
      end

      # POST /api/v1/cities
      def create
        @city = City.new(city_params)
        if @city.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加市#{@city.name}成功")
          render json: { code: 200, success: 1, msg: t("create_success"), data: @city.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加市失败: #{@city.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @city.errors.full_messages.join(","), data: "" }
        end
      end

      # PUT /api/v1/cities/:id
      def update
        if @city.update(city_params)
          gen_log(@current_user.id, @current_ip, params[:action], 1, "修改市#{@city.name}成功")
          render json: { code: 200, success: 1, msg: "ok", data: @city.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "修改市失败: #{@city.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @city.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/cities/:id
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "删除市#{@city.name}成功")
        @city.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      private

      def set_city
        @city = City.find(params[:id]) rescue nil
        if @city.nil?
          gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]} 记录不存在")
          render json: { code: 500, success: 0, msg: "记录不存在！", data: "" }
        end
      end

      def city_params
        params.permit(:province_id, :code, :name, :py)
      end

      def check_authorize
        authorize!(params[:action].to_sym, @city || City)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
  end
end
