# frozen_string_literal: true

module Api
  module V1
    class Pur::ContractsController < BaseController
      before_action :set_contracts, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/pur/contracts
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Pur/contracts列表")

        query = ::Pur::Contract.order("id desc")
        begin
          associations = [:supplier, :client, :kind, :status, :user, :updater]
          associations.select! { |a| ::Pur::Contract.reflections.key?(a) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end

        @q = query.ransack(params[:q])
        @contracts = @q.result()

        if params[:list]
          @contracts = @contracts.where(parent_id: nil) if ::Pur::Contract.column_names.include?("parent_id")
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @contracts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @contracts.size, size: per_page, page: page
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @contracts = @contracts.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, success: 1, msg: "ok",
            data: @contracts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size, size: per_page_num, page: page_num
          }
        end
      end

      # GET /api/v1/pur/contracts/1
      def show
        render json: {
          code: 200, success: 1, msg: "ok",
          data: model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes
        }
      end

      # POST /api/v1/pur/contracts
      def create
        attrs = contracts_params.to_h
        @contracts = ::Pur::Contract.new(attrs)
        create_success = false

        begin
          ::Pur::Contract.transaction do
            unless @contracts.save
              raise ActiveRecord::Rollback
            end
            create_collections if collections_params.present?
            @contracts.generate_iqc_raw_records!(force: false)
            create_success = true
          end
        rescue ActiveRecord::RecordInvalid => e
          @contracts.errors.add(:base, "采购明细创建失败: #{e.record.errors.full_messages.join(', ')}")
        end

        if create_success
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Pur/contracts#{@contracts.contract_title rescue @contracts.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Pur/contracts失败: #{@contracts.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @contracts.errors.full_messages.join(","), data: "" }
        end
      end

      # PATCH/PUT /api/v1/pur/contracts/1
      def update
        attrs = contracts_params.to_h
        update_success = false

        begin
          ::Pur::Contract.transaction do
            unless @contracts.update(attrs)
              raise ActiveRecord::Rollback
            end
            if params.key?(:collections) || params.key?("collections") || (params[:contract] && (params[:contract].key?(:collections) || params[:contract].key?("collections")))
              @contracts.collections.destroy_all
              create_collections if collections_params.present?
              @contracts.generate_iqc_raw_records!(force: true)
            end
            update_success = true
          end
        rescue ActiveRecord::RecordInvalid => e
          @contracts.errors.add(:base, "采购明细更新失败: #{e.record.errors.full_messages.join(', ')}")
        end

        if update_success
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Pur/contracts修改#{@contracts.contract_title rescue @contracts.id}成功")
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@contracts) ? @contracts.base_info : @contracts.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Pur/contracts修改失败: #{@contracts.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @contracts.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/pur/contracts/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Pur/contracts删除#{@contracts.contract_title rescue @contracts.id}成功")
        @contracts.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Pur::Contract.respond_to?(:imp_exp_hander) ? ::Pur::Contract.imp_exp_hander : ::Pur::Contract.column_names
          i18n_column_names = ::Pur::Contract.respond_to?(:il8n_imp_exp_hander) ? ::Pur::Contract.il8n_imp_exp_hander : column_names
          data = []
          file = params[:file_ext] == "csv" ? gen_export_csv_file(data, column_names, i18n_column_names) : gen_export_xlsx_file(data, column_names, i18n_column_names)
          url = file.split("public/")[1]
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
          attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入Pur::Contract")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:contracts].blank?
          ::Pur::Contract.transaction do
            params[:contracts].each do |p|
              c = ::Pur::Contract.new(p.to_unsafe_h)
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
          ::Pur::Contract.transaction do
            params[:ids].each do |id|
              c = ::Pur::Contract.find_by(id: id)
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
          ::Pur::Contract.transaction do
            params[:ids].each do |id|
              c = ::Pur::Contract.find_by(id: id)
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

      def set_contracts
        @contracts = ::Pur::Contract.find(params[:id]) rescue nil
        unless @contracts
          render json: { code: 500, success: 0, msg: "记录不存在！", data: params[:action] }
        end
      end

      def contracts_params
        permitted = [
          :contract_id, :fm_contract_id, :contract_title, :supplier_id, :supplier_name, :client_id, :sign, :client_name,
          :kind_id, :status_id, :code, :contract_number, :signing_location, :signing_date, :receive_date,
          :total_amount, :total_amount_chinese, :related_item, :quality_standard, :delivery_location_method,
          :transportation_cost_bearer, :loss_calculation_method, :packaging_standard, :packaging_loss_responsibility,
          :inspection_method, :reinspection_period, :objection_period, :quality_issue_responsibility,
          :spare_parts_supply, :settlement_method_term, :breach_of_contract_liability, :dispute_resolution_method,
          :other_agreements, :remark, :other, :user_id, :updater_id, :py, :validity_start_date, :validity_end_date
        ]
        params[:contract].present? ? params.require(:contract).permit(permitted) : params.permit(permitted)
      end

      def collections_params
        params[:collections] || params.dig(:contract, :collections) || []
      end

      def create_collections
        Array(collections_params).each do |item_attrs|
          attrs = item_attrs.respond_to?(:to_unsafe_h) ? item_attrs.to_unsafe_h : item_attrs.to_h
          @contracts.collections.create!(
            product_id: attrs["product_id"] || attrs[:product_id],
            product_name: attrs["product_name"] || attrs[:product_name],
            sort: attrs["sort"] || attrs[:sort] || 0,
            length: attrs["length"] || attrs[:length] || 0,
            width: attrs["width"] || attrs[:width] || 0,
            height: attrs["height"] || attrs[:height] || 0,
            unit: attrs["unit"] || attrs[:unit],
            qty: attrs["qty"] || attrs[:qty] || 0,
            price: attrs["price"] || attrs[:price] || 0,
            amount_excl_tax: attrs["amount_excl_tax"] || attrs[:amount_excl_tax] || 0,
            tax: attrs["tax"] || attrs[:tax] || 0,
            amount: attrs["amount"] || attrs[:amount] || 0,
            remark: attrs["remark"] || attrs[:remark],
            other: attrs["other"] || attrs[:other],
            user_id: @current_user&.id
          )
        end
      end

      def check_authorize
        authorize!(params[:action].to_sym, @contracts || ::Pur::Contract)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end

      def model_has_base_info?(model)
        model.respond_to?(:base_info)
      end
    end
  end
end
