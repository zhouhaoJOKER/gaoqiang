# frozen_string_literal: true

# 显式引用避免在 Api::V1::Workflow 命名空间下将 Workflow::Template 解析为 Api::V1::Workflow::Template
module Api
  module V1
    module Workflow
      class TemplatesController < BaseController
        Template = ::Workflow::Template
        before_action :set_template, only: [:show, :update, :destroy, :nodes, :update_node, :edges, :create_edge, :destroy_edge]
        before_action :check_authorize

        # GET /api/v1/workflow/templates
        def index
          query = Template.active.order(:sort, :id)
          @templates = query.paginate(page: params[:page] || 1, per_page: params[:per_page] || 20)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @templates.map { |t| template_base_info(t) },
            total: query.size,
            size: @templates.size,
            page: params[:page] || 1
          }
        end

        # GET /api/v1/workflow/templates/:id
        def show
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: template_detail_info(@template)
          }
        end

        # POST /api/v1/workflow/templates
        def create
          @template = Template.new(template_params)
          if @template.save
            render json: { code: 200, success: 1, msg: "ok", data: template_detail_info(@template) }
          else
            render json: { code: 422, success: 0, msg: @template.errors.full_messages.join(", "), data: nil }
          end
        end

        # PUT /api/v1/workflow/templates/:id
        def update
          if @template.update(template_params)
            render json: { code: 200, success: 1, msg: "ok", data: template_detail_info(@template) }
          else
            render json: { code: 422, success: 0, msg: @template.errors.full_messages.join(", "), data: nil }
          end
        end

        # DELETE /api/v1/workflow/templates/:id
        def destroy
          if @template.destroy
            render json: { code: 200, success: 1, msg: "ok", data: nil }
          else
            render json: { code: 422, success: 0, msg: @template.errors.full_messages.join(", "), data: nil }
          end
        end

        # GET /api/v1/workflow/templates/:id/nodes
        def nodes
          nodes = @template.nodes.order(:sort, :id)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: nodes.map { |n| node_info(n) }
          }
        end

        # PUT /api/v1/workflow/templates/:id/nodes/:key
        def update_node
          node = @template.nodes.find_by!(key: params[:key])
          if node.update(node_params)
            render json: { code: 200, success: 1, msg: "ok", data: node_info(node) }
          else
            render json: { code: 422, success: 0, msg: node.errors.full_messages.join(", "), data: nil }
          end
        end

        # GET /api/v1/workflow/templates/:id/edges
        def edges
          edges = @template.edges.order(:sort, :id)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: edges.map { |e| edge_info(e) }
          }
        end

        # POST /api/v1/workflow/templates/:id/edges
        def create_edge
          edge = @template.edges.build(edge_params)
          if edge.save
            render json: { code: 200, success: 1, msg: "ok", data: edge_info(edge) }
          else
            render json: { code: 422, success: 0, msg: edge.errors.full_messages.join(", "), data: nil }
          end
        end

        # DELETE /api/v1/workflow/templates/:id/edges/:source_key/:target_key
        def destroy_edge
          edge = @template.edges.find_by!(source_key: params[:source_key], target_key: params[:target_key])
          edge.destroy
          render json: { code: 200, success: 1, msg: "ok", data: nil }
        end

        private

        def set_template
          @template = Template.find(params[:id])
        end

        def template_params
          params.permit(:code, :name, :description, :is_default, :sort, :is_active, :user_id, main_step_keys: [])
        end

        def node_params
          params.permit(:label, :description, :position_x, :position_y, :sort, :has_result_options, :node_type)
        end

        def edge_params
          params.permit(:source_key, :target_key, :label, :result_value, :sort)
        end

        def template_base_info(t)
          {
            id: t.id,
            code: t.code,
            name: t.name,
            description: t.description,
            is_default: t.is_default,
            sort: t.sort,
            is_active: t.is_active,
            main_step_keys: t.main_step_keys,
            created_at: t.created_at,
            updated_at: t.updated_at
          }
        end

        def template_detail_info(t)
          template_base_info(t).merge(
            nodes: t.nodes.order(:sort).map { |n| node_info(n) },
            edges: t.edges.order(:sort).map { |e| edge_info(e) },
            node_results: t.node_results.map { |r| node_result_info(r) }
          )
        end

        def node_info(n)
          {
            id: n.id,
            key: n.key,
            label: n.label,
            description: n.description,
            position_x: n.position_x,
            position_y: n.position_y,
            sort: n.sort,
            has_result_options: n.has_result_options,
            node_type: n.node_type,
            created_at: n.created_at,
            updated_at: n.updated_at
          }
        end

        def edge_info(e)
          {
            id: e.id,
            source_key: e.source_key,
            target_key: e.target_key,
            label: e.label,
            result_value: e.result_value,
            sort: e.sort,
            created_at: e.created_at,
            updated_at: e.updated_at
          }
        end

        def node_result_info(r)
          {
            id: r.id,
            node_key: r.node_key,
            result_value: r.result_value,
            result_label: r.result_label,
            target_key: r.target_key,
            sort: r.sort,
            created_at: r.created_at,
            updated_at: r.updated_at
          }
        end

        def check_authorize
          return if @current_user&.admin?
          begin
            authorize!(params[:action].to_sym, @template || Template)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: nil }, status: :forbidden
          end
        end
      end
    end
  end
end
