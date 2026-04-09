# frozen_string_literal: true

module Api
  module V1
    class DocNumberRulesController < BaseController
      before_action :set_doc_number_rule, only: [:show, :update, :destroy]
      before_action :check_authorize

      # POST /api/v1/doc_number_rules/generate - 生成下一个单号（消耗序列）
      # 参数: key (必填) 如 fm_contracts, crm_quotations
      def generate
        key = params[:key].to_s.presence
        unless key.present?
          return render json: { code: 400, success: 0, msg: "参数 key 不能为空", data: nil }, status: :bad_request
        end

        code = DocNumberService.next_number(key)
        gen_log(@current_user.id, @current_ip, "generate", 1, "生成单号 #{key}: #{code}")
        render json: { code: 200, success: 1, msg: "ok", data: { key: key, code: code } }
      end

      # GET /api/v1/doc_number_rules/preview - 预览下一个单号（不消耗序列）
      # 参数: key (必填)
      def preview
        key = params[:key].to_s.presence
        unless key.present?
          return render json: { code: 400, success: 0, msg: "参数 key 不能为空", data: nil }, status: :bad_request
        end

        next_code = DocNumberService.preview(key)
        render json: { code: 200, success: 1, msg: "ok", data: { key: key, code: next_code } }
      end

      # GET /api/v1/doc_number_rules
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问单号规则列表")
        query = DocNumberRule.order(:key)
        @q = query.ransack(params[:q])
        @doc_number_rules = @q.result

        if params[:list]
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @doc_number_rules.map { |e| e.base_info },
            total: @doc_number_rules.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @doc_number_rules = @doc_number_rules.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @doc_number_rules.map { |e| e.base_info },
            total: @q.result.size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/doc_number_rules/:id
      def show
        render json: { code: 200, success: 1, msg: "ok", data: @doc_number_rule.base_info }
      end

      # POST /api/v1/doc_number_rules
      def create
        @doc_number_rule = DocNumberRule.new(doc_number_rule_params)
        if @doc_number_rule.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加单号规则 #{@doc_number_rule.name} 成功")
          render json: { code: 200, success: 1, msg: "创建成功", data: @doc_number_rule.base_info }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加单号规则失败: #{@doc_number_rule.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @doc_number_rule.errors.full_messages.join(","), data: "" }
        end
      end

      # PUT /api/v1/doc_number_rules/:id
      def update
        if @doc_number_rule.update(doc_number_rule_params)
          gen_log(@current_user.id, @current_ip, params[:action], 1, "修改单号规则 #{@doc_number_rule.name} 成功")
          render json: { code: 200, success: 1, msg: "ok", data: @doc_number_rule.base_info }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "修改单号规则失败: #{@doc_number_rule.errors.full_messages.join(',')}")
          render json: { code: 500, success: 0, msg: @doc_number_rule.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/doc_number_rules/:id
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "删除单号规则 #{@doc_number_rule.name} 成功")
        @doc_number_rule.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # POST /api/v1/doc_number_rules/batch_action
      def batch_action
        action = params[:action_type] || params[:action]
        ids = params[:ids] || []
        results = { success: 0, failed: 0, errors: [] }
        data = []

        case action.to_s
        when "delete"
          DocNumberRule.transaction do
            ids.each do |id|
              rule = DocNumberRule.find_by(id: id)
              if rule
                rule.destroy
                results[:success] += 1
                data << rule
              else
                results[:failed] += 1
                results[:errors] << { id: id, errors: ["记录不存在"] }
              end
            end
          end
        else
          return render json: { code: 400, success: 0, msg: "不支持的操作: #{action}", data: [] }
        end

        render json: {
          code: 200, success: 1,
          msg: "批量操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条",
          data: data, results: results
        }
      end

      def import
        render json: { code: 501, success: 0, msg: "暂不支持导入", data: "" }, status: :not_implemented
      end

      private

      def set_doc_number_rule
        @doc_number_rule = DocNumberRule.find_by(id: params[:id])
        return render(json: { code: 500, success: 0, msg: "记录不存在", data: nil }) if @doc_number_rule.nil?
      end

      def doc_number_rule_params
        params.permit(:key, :name, :format, :current_sequence, :reset_period, :last_date)
      end

      def check_authorize
        begin
          authorize!(params[:action].to_sym, @doc_number_rule || DocNumberRule)
        rescue CanCan::AccessDenied
          render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
        end
      end
    end
  end
end
