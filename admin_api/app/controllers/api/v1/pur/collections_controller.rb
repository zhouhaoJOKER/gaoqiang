# frozen_string_literal: true

module Api
  module V1
    class Pur::CollectionsController < BaseController
      before_action :set_collections, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/pur/collections
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Pur/collections列表")

        query = ::Pur::Collection.order("id desc")
        begin
          associations = [:purchase_contract, :product, :user, :updater]
          associations.select! { |a| ::Pur::Collection.reflections.key?(a) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end

        @q = query.ransack(params[:q])
        @collections = @q.result()

        if params[:list]
          @collections = @collections.where(parent_id: nil) if ::Pur::Collection.column_names.include?("parent_id")
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @collections.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @collections.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @collections = @collections.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @collections.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/pur/collections/1
      def show
        render json: {
          code: 200, success: 1, msg: "ok",
          data: model_has_base_info?(@collections) ? @collections.base_info : @collections.attributes
        }
      end

      # POST /api/v1/pur/collections
      def create
        @collections = ::Pur::Collection.new(collections_params)
        if @collections.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Pur/collections#{@collections.product_name rescue @collections.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@collections) ? @collections.base_info : @collections.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Pur/collections失败: #{@collections.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @collections.errors.full_messages.join(","), data: "" }
        end
      end

      # PATCH/PUT /api/v1/pur/collections/1
      def update
        if @collections.update(collections_params)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@collections) ? @collections.base_info : @collections.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Pur/collections修改#{@collections.product_name rescue @collections.id}成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Pur/collections修改失败: #{@collections.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @collections.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/pur/collections/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Pur/collections删除#{@collections.product_name rescue @collections.id}成功")
        @collections.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Pur::Collection.respond_to?(:imp_exp_hander) ? ::Pur::Collection.imp_exp_hander : ::Pur::Collection.column_names
          i18n_column_names = ::Pur::Collection.respond_to?(:il8n_imp_exp_hander) ? ::Pur::Collection.il8n_imp_exp_hander : column_names
          data = []
          file = params[:file_ext] == "csv" ? gen_export_csv_file(data, column_names, i18n_column_names) : gen_export_xlsx_file(data, column_names, i18n_column_names)
          url = file.split("public/")[1]
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
          attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入Pur::Collection")
          csv_data = CSV.read(attachment.file.path, skip_blanks: true)
          headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          render json: { code: 200, success: 1, msg: "success", data: data }
        end
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?
        action = params[:actions]
        valid_actions = %w[create update delete]
        return render json: { code: 500, success: 0, msg: "无效的操作类型", data: "" } unless valid_actions.include?(action)

        data = []
        results = { success: 0, failed: 0, errors: [] }

        case action
        when "create"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:collections].blank?
          ::Pur::Collection.transaction do
            params[:collections].each do |p|
              c = ::Pur::Collection.new(p.to_unsafe_h)
              if c.save
                results[:success] += 1
                data << c
              else
                results[:failed] += 1
                results[:errors] << { params: p, errors: c.errors.full_messages }
              end
            end
          end
        when "update"
          return render json: { code: 500, success: 0, msg: "参数不完整", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?
          update_params = {}
          params[:fields].each { |f| update_params[f.to_sym] = params[:values][f] if params[:values].key?(f) }
          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: "" } if update_params.empty?
          ::Pur::Collection.transaction do
            params[:ids].each do |id|
              c = ::Pur::Collection.find_by(id: id)
              if c&.update(update_params)
                results[:success] += 1
                data << c
              else
                results[:failed] += 1
                results[:errors] << { id: id, errors: c&.errors&.full_messages || ["记录不存在"] }
              end
            end
          end
        when "delete"
          ::Pur::Collection.transaction do
            params[:ids].each do |id|
              c = ::Pur::Collection.find_by(id: id)
              if c
                c.destroy
                results[:success] += 1
              else
                results[:failed] += 1
                results[:errors] << { id: id, errors: ["记录不存在"] }
              end
            end
          end
        end

        render json: { code: 200, success: 1, msg: "批量#{action}完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private

      def set_collections
        @collections = ::Pur::Collection.find(params[:id]) rescue nil
        unless @collections
          render json: { code: 500, success: 0, msg: "记录不存在！", data: params[:action] }
        end
      end

      def collections_params
        params.permit(
          :purchase_contract_id, :sort, :product_id, :product_name, :length, :width, :height,
          :unit, :qty, :price, :amount_excl_tax, :tax, :amount, :user_id, :updater_id, :remark, :other, :py
        )
      end

      def check_authorize
        authorize!(params[:action].to_sym, @collections || ::Pur::Collection)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end

      def model_has_base_info?(model)
        model.respond_to?(:base_info)
      end
    end
  end
end
