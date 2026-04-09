module Api
  module V1
    class Mfg::WorkOrderByproductsController < BaseController
      before_action :set_work_order_byproduct, only: [:show, :update, :destroy]
      before_action :check_authorize

      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mfg/work_order_byproduct列表")
        query = ::Mfg::WorkOrderByproduct.order("id desc")
        begin
          associations = [:work_order, :bom_byproduct, :product, :user, :updater]
          associations.select! { |assoc| ::Mfg::WorkOrderByproduct.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        @q = query.ransack(params[:q])
        @work_order_byproducts = @q.result()
        if params[:list]
          render json: { code: 200, success: 1, msg: "ok", data: @work_order_byproducts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @work_order_byproducts.size, size: per_page, page: page }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @work_order_byproducts = @work_order_byproducts.paginate(page: page_num, per_page: per_page_num)
          render json: { code: 200, success: 1, msg: "ok", data: @work_order_byproducts.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, total: @q.result().size, size: per_page_num, page: page_num }
        end
      end

      def show
        render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@work_order_byproduct) ? @work_order_byproduct.base_info : @work_order_byproduct.attributes }
      end

      def create
        @work_order_byproduct = ::Mfg::WorkOrderByproduct.new(work_order_byproduct_params)
        @work_order_byproduct.user_id = @current_user.id if @work_order_byproduct.respond_to?(:user_id) && @work_order_byproduct.user_id.nil?
        if @work_order_byproduct.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mfg/work_order_byproduct#{@work_order_byproduct.code rescue @work_order_byproduct.id}成功")
          render json: { code: 200, success: 1, msg: t('create_success'), data: model_has_base_info?(@work_order_byproduct) ? @work_order_byproduct.base_info : @work_order_byproduct.attributes }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mfg/work_order_byproduct失败: #{@work_order_byproduct.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @work_order_byproduct.errors.full_messages.join(","), data: "" }
        end
      end

      def update
        work_order_byproduct_params_hash = work_order_byproduct_params.to_h
        work_order_byproduct_params_hash[:updater_id] = @current_user.id if @work_order_byproduct.respond_to?(:updater_id)
        if @work_order_byproduct.update(work_order_byproduct_params_hash)
          render json: { code: 200, success: 1, msg: "ok", data: model_has_base_info?(@work_order_byproduct) ? @work_order_byproduct.base_info : @work_order_byproduct.attributes }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/work_order_byproduct修改#{@work_order_byproduct.code rescue @work_order_byproduct.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mfg/work_order_byproduct修改#{@work_order_byproduct.code rescue @work_order_byproduct.id} 失败: #{@work_order_byproduct.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @work_order_byproduct.errors.full_messages.join(","), data: "" }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mfg/work_order_byproduct删除#{@work_order_byproduct.code rescue @work_order_byproduct.id}成功")
        @work_order_byproduct.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Mfg::WorkOrderByproduct.respond_to?(:imp_exp_hander) ? ::Mfg::WorkOrderByproduct.imp_exp_hander : ::Mfg::WorkOrderByproduct.column_names
          i18n_column_names = ::Mfg::WorkOrderByproduct.respond_to?(:il8n_imp_exp_hander) ? ::Mfg::WorkOrderByproduct.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mfg/work_order_byproduct模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(file: params[:file], user_id: @current_user.id, name: "导入::Mfg::WorkOrderByproduct.table_name")
          file = attachment.file.path
          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data
          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mfg/work_order_byproduct预览数据成功")
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:work_order_byproducts].blank?
          ::Mfg::WorkOrderByproduct.transaction do
            params[:work_order_byproducts].each do |work_order_byproduct_params|
              work_order_byproduct = ::Mfg::WorkOrderByproduct.new(work_order_byproduct_params.to_unsafe_h)
              if work_order_byproduct.save
                results[:success] += 1
                data << work_order_byproduct
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mfg/work_order_byproduct#{work_order_byproduct.code rescue work_order_byproduct.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: work_order_byproduct_params, errors: work_order_byproduct.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mfg/work_order_byproduct#{work_order_byproduct_params[:code]}失败: #{work_order_byproduct.errors.full_messages.join(",")}")
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
          ::Mfg::WorkOrderByproduct.transaction do
            selected_ids.each do |work_order_byproduct_id|
              work_order_byproduct = ::Mfg::WorkOrderByproduct.find_by(id: work_order_byproduct_id)
              if work_order_byproduct
                if work_order_byproduct.update(update_params)
                  results[:success] += 1
                  data << work_order_byproduct
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mfg/work_order_byproduct#{work_order_byproduct.code rescue work_order_byproduct.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: work_order_byproduct_id, errors: work_order_byproduct.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/work_order_byproduct#{work_order_byproduct.code rescue work_order_byproduct.id}失败: #{work_order_byproduct.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: work_order_byproduct_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mfg/work_order_byproduct失败: 记录ID #{work_order_byproduct_id} 不存在")
              end
            end
          end
        when "delete"
          ::Mfg::WorkOrderByproduct.transaction do
            params[:ids].each do |work_order_byproduct_id|
              work_order_byproduct = ::Mfg::WorkOrderByproduct.find(work_order_byproduct_id)
              if work_order_byproduct
                work_order_byproduct.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mfg/work_order_byproduct#{work_order_byproduct.code rescue work_order_byproduct.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: work_order_byproduct_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mfg/work_order_byproduct失败: 记录ID #{work_order_byproduct_id} 不存在")
              end
            end
          end
        end
        render json: { code: 200, success: 1, msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条", data: data, results: results }
      end

      private
        def set_work_order_byproduct
          @work_order_byproduct = ::Mfg::WorkOrderByproduct.find(params[:id]) rescue nil
          if @work_order_byproduct.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def work_order_byproduct_params
          params.permit(:work_order_id, :bom_byproduct_id, :product_id, :plan_qty, :actual_qty, :user_id, :updater_id)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @work_order_byproduct || ::Mfg::WorkOrderByproduct)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
