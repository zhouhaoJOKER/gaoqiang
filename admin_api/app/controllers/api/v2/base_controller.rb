# frozen_string_literal: true

module Api
  module V2
    # 公开预购等接口：仅校验 PREORDER_API_TOKEN（Bearer 或 X-Pre-Order-Token），不要求用户登录
    class BaseController < ActionController::API
      before_action :authenticate_preorder_token

      private

      def authenticate_preorder_token
        expected = preorder_expected_token
        given = extract_preorder_token.to_s
        unless token_matches?(given, expected)
          render json: { code: 401, success: 0, msg: "无效的预购接口令牌", data: nil }, status: :unauthorized
        end
      end

      def preorder_expected_token
        ENV["PREORDER_API_TOKEN"].presence || "dev-preorder-token-change-me"
      end

      def extract_preorder_token
        auth = request.headers["Authorization"].to_s
        if auth.start_with?("Bearer ")
          auth.split(" ", 2).last&.strip
        else
          request.headers["X-Pre-Order-Token"].presence
        end
      end

      def token_matches?(given, expected)
        return false if given.blank? || expected.blank?

        if given.bytesize == expected.bytesize
          ActiveSupport::SecurityUtils.secure_compare(given, expected)
        else
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(given),
            ::Digest::SHA256.hexdigest(expected)
          )
        end
      end

      def page
        params[:page].present? ? params[:page].to_i : 1
      end

      def per_page
        if params[:per_page].present?
          params[:per_page].to_i
        elsif params[:size].present?
          params[:size].to_i
        else
          20
        end
      end
    end
  end
end
