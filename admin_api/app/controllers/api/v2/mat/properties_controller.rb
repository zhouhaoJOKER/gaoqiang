# frozen_string_literal: true

module Api
  module V2
    module Mat
      class PropertiesController < Api::V2::BaseController
        # GET /api/v2/mat/properties
        def index
          query = ::Property.order("sort desc")
          begin
            associations = [:company, :parent, :children]
            associations.select! { |assoc| ::Property.reflections.key?(assoc) }
            query = query.includes(*associations) unless associations.empty?
          rescue StandardError
            # ignore
          end

          @q = query.ransack(params[:q])
          @properties = @q.result

          if params[:list]
            @properties = @properties.where(parent_id: nil) if ::Property.column_names.include?("parent_id")
            render json: {
              code: 200,
              success: 1,
              msg: "ok",
              data: @properties.map { |e| e.respond_to?(:base_info) ? e.base_info : e.attributes },
              total: @properties.size,
              size: per_page,
              page: page
            }
          else
            page_num = params[:page] || params[:current] || 1
            per_page_num = params[:per_page] || params[:size] || per_page
            @properties = @properties.paginate(page: page_num, per_page: per_page_num)
            render json: {
              code: 200,
              success: 1,
              msg: "ok",
              data: @properties.map { |e| e.respond_to?(:base_info) ? e.base_info : e.attributes },
              total: @q.result.size,
              size: per_page_num,
              page: page_num
            }
          end
        end
      end
    end
  end
end
