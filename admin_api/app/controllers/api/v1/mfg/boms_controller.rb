module Api
  module V1
    class Mfg::BomsController < BaseController
      before_action :set_bom, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/bom列表")
        query = ::Mfg::Bom.order("id desc")
        begin
          associations = [:company, :user, :updater, :product, :uom, :type, :bom_lines, :bom_byproducts]
          associations.select! { |assoc| ::Mfg::Bom.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @boms = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @boms.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @boms.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @boms = @boms.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @boms.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom) ? @bom.base_info : @bom.attributes }
      end

      def create
        @bom = ::Mfg::Bom.new(bom_params)
        @bom.user_id = @current_user.id if @bom.respond_to?(:user_id) && @bom.user_id.nil?

        ::Mfg::Bom.transaction do
          if @bom.save
            # 创建 BOM 明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                line = @bom.bom_lines.build(
                  product_id:        line_params[:product_id],
                  product_qty:       line_params[:product_qty],
                  product_uom_id:    line_params[:product_uom_id],
                  operation_id:      line_params[:operation_id],
                  optional:          line_params[:optional],
                  alternative:       line_params[:alternative],
                  sort:              line_params[:sort],
                  user_id:           @current_user.id
                )
                unless line.save
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/bom明细失败: #{line.errors.full_messages.join(",")}")
                  raise ActiveRecord::Rollback
                end
              end
            end

            # 创建 BOM 副产品/废料
            if params[:byproducts].present? && params[:byproducts].is_a?(Array)
              params[:byproducts].each do |bp_params|
                byproduct = @bom.bom_byproducts.build(
                  product_id:        bp_params[:product_id],
                  product_qty:       bp_params[:product_qty],
                  product_uom_id:    bp_params[:product_uom_id],
                  output_category:   bp_params[:output_category],
                  is_inventory:      bp_params[:is_inventory],
                  sort:              bp_params[:sort],
                  user_id:           @current_user.id
                )
                unless byproduct.save
                  gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/bom副产品/废料失败: #{byproduct.errors.full_messages.join(",")}")
                  raise ActiveRecord::Rollback
                end
              end
            end

            gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/bom#{@bom.code rescue @bom.id}成功")
            render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@bom) ? @bom.base_info : @bom.attributes }
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/bom失败: #{@bom.errors.full_messages.join(",")}")
            render json: { code: 500, success: 0, msg: @bom.errors.full_messages.join(","), data: "" }
          end
        end
      end

      def update
        bom_params_hash = bom_params.to_h
        bom_params_hash[:updater_id] = @current_user.id if @bom.respond_to?(:updater_id)

        ::Mfg::Bom.transaction do
          if @bom.update(bom_params_hash)
            # 更新 / 新增 BOM 明细行
            if params[:lines].present? && params[:lines].is_a?(Array)
              params[:lines].each do |line_params|
                if line_params[:id].present?
                  line = @bom.bom_lines.find_by(id: line_params[:id])
                  if line
                    unless line.update(
                      product_id:        line_params[:product_id],
                      product_qty:       line_params[:product_qty],
                      product_uom_id:    line_params[:product_uom_id],
                      operation_id:      line_params[:operation_id],
                      optional:          line_params[:optional],
                      alternative:       line_params[:alternative],
                      sort:              line_params[:sort],
                      updater_id:        @current_user.id
                    )
                      gen_log(@current_user.id, @current_ip, params[:action], 0, "更新Mfg/bom明细失败: #{line.errors.full_messages.join(",")}")
                      raise ActiveRecord::Rollback
                    end
                  end
                else
                  line = @bom.bom_lines.build(
                    product_id:        line_params[:product_id],
                    product_qty:       line_params[:product_qty],
                    product_uom_id:    line_params[:product_uom_id],
                    operation_id:      line_params[:operation_id],
                    optional:          line_params[:optional],
                    alternative:       line_params[:alternative],
                    sort:              line_params[:sort],
                    user_id:           @current_user.id
                  )
                  unless line.save
                    gen_log(@current_user.id, @current_ip, params[:action], 0, "新增Mfg/bom明细失败: #{line.errors.full_messages.join(",")}")
                    raise ActiveRecord::Rollback
                  end
                end
              end
            end

            # 更新 / 新增 副产品/废料
            if params[:byproducts].present? && params[:byproducts].is_a?(Array)
              params[:byproducts].each do |bp_params|
                if bp_params[:id].present?
                  byproduct = @bom.bom_byproducts.find_by(id: bp_params[:id])
                  if byproduct
                    unless byproduct.update(
                      product_id:        bp_params[:product_id],
                      product_qty:       bp_params[:product_qty],
                      product_uom_id:    bp_params[:product_uom_id],
                      output_category:   bp_params[:output_category],
                      is_inventory:      bp_params[:is_inventory],
                      sort:              bp_params[:sort],
                      updater_id:        @current_user.id
                    )
                      gen_log(@current_user.id, @current_ip, params[:action], 0, "更新Mfg/bom副产品/废料失败: #{byproduct.errors.full_messages.join(",")}")
                      raise ActiveRecord::Rollback
                    end
                  end
                else
                  byproduct = @bom.bom_byproducts.build(
                    product_id:        bp_params[:product_id],
                    product_qty:       bp_params[:product_qty],
                    product_uom_id:    bp_params[:product_uom_id],
                    output_category:   bp_params[:output_category],
                    is_inventory:      bp_params[:is_inventory],
                    sort:              bp_params[:sort],
                    user_id:           @current_user.id
                  )
                  unless byproduct.save
                    gen_log(@current_user.id, @current_ip, params[:action], 0, "新增Mfg/bom副产品/废料失败: #{byproduct.errors.full_messages.join(",")}")
                    raise ActiveRecord::Rollback
                  end
                end
              end
            end

            render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom) ? @bom.base_info : @bom.attributes }
            gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom修改#{@bom.code rescue @bom.id} 成功")
          else
            gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/bom修改#{@bom.code rescue @bom.id} 失败: @#{@bom.errors.full_messages.join(",")}")
            render json: { code: 500, success: 0, msg: @bom.errors.full_messages.join(","), data: "" }
          end
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom删除#{@bom.code rescue @bom.id}成功")
        @bom.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::Bom.respond_to?(:imp_exp_hander) ? ::Mfg::Bom.imp_exp_hander : ::Mfg::Bom.column_names
          i18n_column_names = ::Mfg::Bom.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::Bom.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/bom模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::Bom.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/bom预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?
        action = params[:actions]
        valid_actions = [ "create", "update", "delete" ]
        return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
        data = []
        results = { success: 0, failed: 0, errors: [] }
        case action
        when "create"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:boms].blank?
          ::Mfg::Bom.transaction do
            params[:boms].each do |bom_params|
              bom = ::Mfg::Bom.new(bom_params.to_unsafe_h)
              if bom.save
                results[:success] += 1
                data << bom
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/bom#{bom.code rescue bom.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: bom_params, errors: bom.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/bom#{bom_params[:code]}失败: #{bom.errors.full_messages.join(",")}")
              end
            end
          end
        when "update"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?
          selected_ids = params[:ids]
          fields = params[:fields]
          values = params[:values]
          update_params = {}
          fields.each do |field|
            update_params[field.to_sym] = values[field] if values.key?(field)
          end
          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?
          ::Mfg::Bom.transaction do
            selected_ids.each do |bom_id|
              bom = ::Mfg::Bom.find_by(id: bom_id)
              if bom
                if bom.update(update_params)
                  results[:success] += 1
                  data << bom
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/bom#{bom.code rescue bom.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: bom_id, errors: bom.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom#{bom.code rescue bom.id}失败: #{bom.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: bom_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom失败: 记录ID #{bom_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::Bom.transaction do
            params[:ids].each do |bom_id|
              bom = ::Mfg::Bom.find(bom_id)
              if bom
                bom.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/bom#{bom.code rescue bom.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: bom_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/bom失败: 记录ID #{bom_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_bom
          @bom = ::Mfg::Bom.includes(:type, :product, :uom, :bom_lines, :bom_byproducts).find(params[:id]) rescue nil
          if @bom.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def bom_params
          # 只接收主表字段，lines/byproducts 单独处理
          if params[:bom].is_a?(ActionController::Parameters)
            params.require(:bom).permit(:code, :product_id, :type_id, :product_qty, :uom_id, :is_active, :is_default, :ready_to_produce, :picking_type_id, :company_id, :user_id, :updater_id)
          else
            params.permit(:code, :product_id, :type_id, :product_qty, :uom_id, :is_active, :is_default, :ready_to_produce, :picking_type_id, :company_id, :user_id, :updater_id)
          end
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @bom || ::Mfg::Bom)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
