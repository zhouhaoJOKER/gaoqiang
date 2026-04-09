module Api
  module V1
    class Mfg::WorkOrderLossesController < BaseController
      before_action :set_work_order_loss, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/work_order_loss列表")
        query = ::Mfg::WorkOrderLoss.order("id desc")
        begin
          associations = [:work_order, :bom_loss, :product, :user, :updater]
          associations.select! { |assoc| ::Mfg::WorkOrderLoss.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @work_order_losses = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @work_order_losses.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @work_order_losses.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @work_order_losses = @work_order_losses.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @work_order_losses.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@work_order_loss) ? @work_order_loss.base_info : @work_order_loss.attributes }
      end

      def create
        @work_order_loss = ::Mfg::WorkOrderLoss.new(work_order_loss_params)
        @work_order_loss.user_id = @current_user.id if @work_order_loss.respond_to?(:user_id) && @work_order_loss.user_id.nil?
        if @work_order_loss.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/work_order_loss#{@work_order_loss.code rescue @work_order_loss.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@work_order_loss) ? @work_order_loss.base_info : @work_order_loss.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/work_order_loss失败: #{@work_order_loss.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @work_order_loss.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        work_order_loss_params_hash = work_order_loss_params.to_h
        work_order_loss_params_hash[:updater_id] = @current_user.id if @work_order_loss.respond_to?(:updater_id)
        if @work_order_loss.update(work_order_loss_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@work_order_loss) ? @work_order_loss.base_info : @work_order_loss.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/work_order_loss修改#{@work_order_loss.code rescue @work_order_loss.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/work_order_loss修改#{@work_order_loss.code rescue @work_order_loss.id} 失败: #{@work_order_loss.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @work_order_loss.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/work_order_loss删除#{@work_order_loss.code rescue @work_order_loss.id}成功")
        @work_order_loss.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::WorkOrderLoss.respond_to?(:imp_exp_hander) ? ::Mfg::WorkOrderLoss.imp_exp_hander : ::Mfg::WorkOrderLoss.column_names
          i18n_column_names = ::Mfg::WorkOrderLoss.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::WorkOrderLoss.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/work_order_loss模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::WorkOrderLoss.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/work_order_loss预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:work_order_losses].blank?
          ::Mfg::WorkOrderLoss.transaction do
            params[:work_order_losses].each do |work_order_loss_params|
              work_order_loss = ::Mfg::WorkOrderLoss.new(work_order_loss_params.to_unsafe_h)
              if work_order_loss.save
                results[:success] += 1
                data << work_order_loss
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/work_order_loss#{work_order_loss.code rescue work_order_loss.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: work_order_loss_params, errors: work_order_loss.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/work_order_loss#{work_order_loss_params[:code]}失败: #{work_order_loss.errors.full_messages.join(",")}")
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
          ::Mfg::WorkOrderLoss.transaction do
            selected_ids.each do |work_order_loss_id|
              work_order_loss = ::Mfg::WorkOrderLoss.find_by(id: work_order_loss_id)
              if work_order_loss
                if work_order_loss.update(update_params)
                  results[:success] += 1
                  data << work_order_loss
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/work_order_loss#{work_order_loss.code rescue work_order_loss.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: work_order_loss_id, errors: work_order_loss.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/work_order_loss#{work_order_loss.code rescue work_order_loss.id}失败: #{work_order_loss.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: work_order_loss_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/work_order_loss失败: 记录ID #{work_order_loss_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::WorkOrderLoss.transaction do
            params[:ids].each do |work_order_loss_id|
              work_order_loss = ::Mfg::WorkOrderLoss.find(work_order_loss_id)
              if work_order_loss
                work_order_loss.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/work_order_loss#{work_order_loss.code rescue work_order_loss.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: work_order_loss_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/work_order_loss失败: 记录ID #{work_order_loss_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_work_order_loss
          @work_order_loss = ::Mfg::WorkOrderLoss.find(params[:id]) rescue nil
          if @work_order_loss.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def work_order_loss_params
          params.permit(:work_order_id, :bom_loss_id, :product_id, :plan_loss_qty, :actual_loss_qty, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @work_order_loss || ::Mfg::WorkOrderLoss)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
