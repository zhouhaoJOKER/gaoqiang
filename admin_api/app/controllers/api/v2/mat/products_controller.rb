# frozen_string_literal: true

module Api
  module V2
    module Mat
      class ProductsController < Api::V2::BaseController
        # GET /api/v2/mat/products
        def index
          query = ::Mat::Product.order("id desc")

          if params[:spec_category_id].present?
            query = query.where(category_id: params[:spec_category_id])
          elsif params[:parent_category_id].present?
            child_ids = ::Property.where(
              sign: "product_category",
              parent_id: params[:parent_category_id]
            ).pluck(:id)
            query = if child_ids.any?
                      query.where(category_id: child_ids)
                    else
                      query.none
                    end
          end

          begin
            associations = [:company, :category, :parent, :children]
            associations.select! { |assoc| ::Mat::Product.reflections.key?(assoc) }
            query = query.includes(*associations) unless associations.empty?
          rescue StandardError
            # ignore
          end

          @q = query.ransack(params[:q])
          @products = @q.result

          if params[:list]
            @products = @products.where(parent_id: nil) if ::Mat::Product.column_names.include?("parent_id")
            render json: {
              code: 200,
              success: 1,
              msg: "ok",
              data: @products.map { |e| e.respond_to?(:base_info) ? e.base_info : e.attributes },
              total: @products.size,
              size: per_page,
              page: page
            }
          else
            page_num = params[:page] || params[:current] || 1
            per_page_num = params[:per_page] || params[:size] || per_page
            @products = @products.paginate(page: page_num, per_page: per_page_num)
            render json: {
              code: 200,
              success: 1,
              msg: "ok",
              data: @products.map { |e| e.respond_to?(:base_info) ? e.base_info : e.attributes },
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
