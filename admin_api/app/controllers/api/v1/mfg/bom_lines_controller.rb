module Api
  module V1
    class Mfg::BomLinesController < BaseController
      before_action :set_bom_line, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/bom_line列表")
        query = ::Mfg::BomLine.order("id desc")
        begin
          associations = [:bom, :user, :updater, :product, :product_uom, :bom_losses]
          associations.select! { |assoc| ::Mfg::BomLine.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @bom_lines = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @bom_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @bom_lines.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @bom_lines = @bom_lines.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @bom_lines.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom_line) ? @bom_line.base_info : @bom_line.attributes }
      end

      def create
        @bom_line = ::Mfg::BomLine.new(bom_line_params)
        @bom_line.user_id = @current_user.id if @bom_line.respond_to?(:user_id) && @bom_line.user_id.nil?
        if @bom_line.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/bom_line#{@bom_line.code rescue @bom_line.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@bom_line) ? @bom_line.base_info : @bom_line.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/bom_line失败: #{@bom_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @bom_line.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        bom_line_params_hash = bom_line_params.to_h
        bom_line_params_hash[:updater_id] = @current_user.id if @bom_line.respond_to?(:updater_id)
        if @bom_line.update(bom_line_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom_line) ? @bom_line.base_info : @bom_line.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom_line修改#{@bom_line.code rescue @bom_line.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/bom_line修改#{@bom_line.code rescue @bom_line.id} 失败: #{@bom_line.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @bom_line.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom_line删除#{@bom_line.code rescue @bom_line.id}成功")
        @bom_line.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::BomLine.respond_to?(:imp_exp_hander) ? ::Mfg::BomLine.imp_exp_hander : ::Mfg::BomLine.column_names
          i18n_column_names = ::Mfg::BomLine.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::BomLine.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/bom_line模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::BomLine.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/bom_line预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:bom_lines].blank?
          ::Mfg::BomLine.transaction do
            params[:bom_lines].each do |bom_line_params|
              bom_line = ::Mfg::BomLine.new(bom_line_params.to_unsafe_h)
              if bom_line.save
                results[:success] += 1
                data << bom_line
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/bom_line#{bom_line.code rescue bom_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: bom_line_params, errors: bom_line.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/bom_line#{bom_line_params[:code]}失败: #{bom_line.errors.full_messages.join(",")}")
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
          ::Mfg::BomLine.transaction do
            selected_ids.each do |bom_line_id|
              bom_line = ::Mfg::BomLine.find_by(id: bom_line_id)
              if bom_line
                if bom_line.update(update_params)
                  results[:success] += 1
                  data << bom_line
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/bom_line#{bom_line.code rescue bom_line.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: bom_line_id, errors: bom_line.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom_line#{bom_line.code rescue bom_line.id}失败: #{bom_line.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: bom_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom_line失败: 记录ID #{bom_line_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::BomLine.transaction do
            params[:ids].each do |bom_line_id|
              bom_line = ::Mfg::BomLine.find(bom_line_id)
              if bom_line
                bom_line.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/bom_line#{bom_line.code rescue bom_line.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: bom_line_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/bom_line失败: 记录ID #{bom_line_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_bom_line
          @bom_line = ::Mfg::BomLine.find(params[:id]) rescue nil
          if @bom_line.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def bom_line_params
          params.permit(:bom_id, :product_id, :product_qty, :product_uom_id, :operation_id, :optional, :alternative, :sort, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @bom_line || ::Mfg::BomLine)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
