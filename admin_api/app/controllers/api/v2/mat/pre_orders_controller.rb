# frozen_string_literal: true

module Api
  module V2
    module Mat
      class PreOrdersController < Api::V2::BaseController
        # POST /api/v2/mat/pre_orders
        def create
          p = preorder_params
          rec = ::Mat::PreOrder.new(
            customer_name: p[:customer_name],
            customer_code: p[:customer_code],
            spec_requirements: p[:spec_requirements],
            line_items: normalize_line_items(p[:line_items]),
            status: ::Mat::PreOrder::STATUS_PENDING,
            request_ip: request.remote_ip
          )
          if rec.save
            render json: {
              code: 200,
              success: 1,
              msg: "预购单已提交",
              data: { id: rec.id }
            }
          else
            render json: {
              code: 422,
              success: 0,
              msg: rec.errors.full_messages.join("；"),
              data: nil
            }, status: :unprocessable_entity
          end
        end

        private

        def preorder_params
          params.permit(
            :customer_name,
            :customer_code,
            :spec_requirements,
            line_items: %i[
              product_id
              product_name
              model
              color
              weight
              quantity
              unit
            ]
          )
        end

        def normalize_line_items(raw)
          items =
            case raw
            when Array then raw
            when ActionController::Parameters
              raw.to_unsafe_h.is_a?(Hash) ? raw.to_unsafe_h.values : []
            when Hash
              raw.values
            else
              []
            end
          items.map do |row|
            h = (row.respond_to?(:to_unsafe_h) ? row.to_unsafe_h : row).to_h.stringify_keys
            {
              "product_id" => h["product_id"],
              "product_name" => h["product_name"],
              "model" => h["model"],
              "color" => h["color"],
              "weight" => h["weight"],
              "quantity" => h["quantity"].present? ? h["quantity"].to_f : 0.0,
              "unit" => h["unit"]
            }
          end
        end
      end
    end
  end
end
