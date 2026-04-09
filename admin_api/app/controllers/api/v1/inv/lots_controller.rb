module Api
  module V1
    class Inv::LotsController < BaseController
      before_action :set_lot, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/inv/lots
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Inv/lot列表")
        
        # 基础查询
        query = ::Inv::Lot.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :item, :product, :user]
          # 只包含存在的关联
          associations.select! { |assoc| ::Inv::Lot.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @lots = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @lots.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @lots.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @lots = @lots.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @lots.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/inv/lots/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@lot) ? @lot.base_info : @lot.attributes 
        }
      end

      # POST /api/v1/inv/lots
      def create
        @lot = ::Inv::Lot.new(lot_params)
        @lot.user_id = @current_user.id if @lot.respond_to?(:user_id) && @lot.user_id.nil?

        
        if @lot.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Inv/lot#{@lot.code rescue @lot.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@lot) ? @lot.base_info : @lot.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Inv/lot失败: #{@lot.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @lot.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/inv/lots/1
      def update
        lot_params_hash = lot_params.to_h
        if @lot.update(lot_params_hash)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@lot) ? @lot.base_info : @lot.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/lot修改#{@lot.code rescue @lot.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Inv/lot修改#{@lot.code rescue @lot.id} 失败: #{@lot.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @lot.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/inv/lots/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Inv/lot删除#{@lot.code rescue @lot.id}成功")
        @lot.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # 导入功能
      # post api/v1/inv/lots/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Inv::Lot.respond_to?(:imp_exp_hander) ? ::Inv::Lot.imp_exp_hander : ::Inv::Lot.column_names
          i18n_column_names = ::Inv::Lot.respond_to?(:il8n_imp_exp_hander) ? ::Inv::Lot.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Inv/lot模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Inv::Lot.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Inv/lot预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/inv/lots/batch_action
      def batch_action
        return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?

        action = params[:actions]
        valid_actions = [ "create", "update", "delete" ]
        return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
        data = []
        results = {
          success: 0,
          failed: 0,
          errors: []
        }
        case action
        when "create"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:lots].blank?

          ::Inv::Lot.transaction do
            params[:lots].each do |lot_params|
              lot = ::Inv::Lot.new(lot_params.to_unsafe_h)
              if lot.save
                results[:success] += 1
                data << lot
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Inv/lot#{lot.code rescue lot.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: lot_params, errors: lot.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Inv/lot#{lot_params[:code]}失败: #{lot.errors.full_messages.join(",")}")
              end
            end
          end

        when "update"
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?

          selected_ids = params[:ids]
          fields = params[:fields]
          values = params[:values]

          # 过滤出需要更新的字段和值
          update_params = {}
          fields.each do |field|
            update_params[field.to_sym] = values[field] if values.key?(field)
          end

          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?

          ::Inv::Lot.transaction do
            selected_ids.each do |lot_id|
              lot = ::Inv::Lot.find_by(id: lot_id)
              if lot
                if lot.update(update_params)
                  results[:success] += 1
                  data << lot
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Inv/lot#{lot.code rescue lot.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: lot_id, errors: lot.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/lot#{lot.code rescue lot.id}失败: #{lot.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: lot_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Inv/lot失败: 记录ID #{lot_id} 不存在")
              end
            end
          end

        when "delete"
          ::Inv::Lot.transaction do
            params[:ids].each do |lot_id|
              lot = ::Inv::Lot.find(lot_id)
              if lot
                lot.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Inv/lot#{lot.code rescue lot.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: lot_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Inv/lot失败: 记录ID #{lot_id} 不存在")
              end
            end
          end
        end

        render json: {
          code: 200,
          success: 1,
          msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条",
          data: data,
          results: results
        }
      end

      private
        def set_lot
          @lot = ::Inv::Lot.find(params[:id]) rescue nil
          if @lot.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def lot_params
          params.permit(:code, :item_id, :product_id, :company_id, :ref, :qty, :unit_cost, :expiration_date, :alert_date, :removal_date, :order_type, :order_id, :order_line_id, :user_id, :description)
        end
        
        # 辅助方法：检查模型是否有base_info方法
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        # 权限校验方法
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @lot || ::Inv::Lot)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
