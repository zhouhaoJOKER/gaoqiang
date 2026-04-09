module Api
  module V1
    class Mfg::BomLossesController < BaseController
      before_action :set_bom_loss, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/bom_loss列表")
        query = ::Mfg::BomLoss.order("id desc")
        begin
          associations = [:bom_line, :user, :updater]
          associations.select! { |assoc| ::Mfg::BomLoss.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @bom_losses = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @bom_losses.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @bom_losses.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @bom_losses = @bom_losses.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @bom_losses.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom_loss) ? @bom_loss.base_info : @bom_loss.attributes }
      end

      def create
        @bom_loss = ::Mfg::BomLoss.new(bom_loss_params)
        @bom_loss.user_id = @current_user.id if @bom_loss.respond_to?(:user_id) && @bom_loss.user_id.nil?
        if @bom_loss.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/bom_loss#{@bom_loss.code rescue @bom_loss.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@bom_loss) ? @bom_loss.base_info : @bom_loss.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/bom_loss失败: #{@bom_loss.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @bom_loss.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        bom_loss_params_hash = bom_loss_params.to_h
        bom_loss_params_hash[:updater_id] = @current_user.id if @bom_loss.respond_to?(:updater_id)
        if @bom_loss.update(bom_loss_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@bom_loss) ? @bom_loss.base_info : @bom_loss.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom_loss修改#{@bom_loss.code rescue @bom_loss.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/bom_loss修改#{@bom_loss.code rescue @bom_loss.id} 失败: #{@bom_loss.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @bom_loss.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/bom_loss删除#{@bom_loss.code rescue @bom_loss.id}成功")
        @bom_loss.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::BomLoss.respond_to?(:imp_exp_hander) ? ::Mfg::BomLoss.imp_exp_hander : ::Mfg::BomLoss.column_names
          i18n_column_names = ::Mfg::BomLoss.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::BomLoss.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/bom_loss模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::BomLoss.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/bom_loss预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:bom_losses].blank?
          ::Mfg::BomLoss.transaction do
            params[:bom_losses].each do |bom_loss_params|
              bom_loss = ::Mfg::BomLoss.new(bom_loss_params.to_unsafe_h)
              if bom_loss.save
                results[:success] += 1
                data << bom_loss
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/bom_loss#{bom_loss.code rescue bom_loss.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: bom_loss_params, errors: bom_loss.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/bom_loss#{bom_loss_params[:code]}失败: #{bom_loss.errors.full_messages.join(",")}")
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
          ::Mfg::BomLoss.transaction do
            selected_ids.each do |bom_loss_id|
              bom_loss = ::Mfg::BomLoss.find_by(id: bom_loss_id)
              if bom_loss
                if bom_loss.update(update_params)
                  results[:success] += 1
                  data << bom_loss
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/bom_loss#{bom_loss.code rescue bom_loss.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: bom_loss_id, errors: bom_loss.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom_loss#{bom_loss.code rescue bom_loss.id}失败: #{bom_loss.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: bom_loss_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/bom_loss失败: 记录ID #{bom_loss_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::BomLoss.transaction do
            params[:ids].each do |bom_loss_id|
              bom_loss = ::Mfg::BomLoss.find(bom_loss_id)
              if bom_loss
                bom_loss.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/bom_loss#{bom_loss.code rescue bom_loss.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: bom_loss_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/bom_loss失败: 记录ID #{bom_loss_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_bom_loss
          @bom_loss = ::Mfg::BomLoss.find(params[:id]) rescue nil
          if @bom_loss.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def bom_loss_params
          params.permit(:bom_line_id, :loss_mode, :loss_value, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @bom_loss || ::Mfg::BomLoss)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
