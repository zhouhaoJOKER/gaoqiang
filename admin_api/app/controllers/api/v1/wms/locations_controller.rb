module Api
  module V1
    class Wms::LocationsController < BaseController
      before_action :set_location, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/wms/locations
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Wms/location列表")
        
        query = ::Wms::Location.order("id desc")
        
        begin
          associations = [:warehouse, :area, :user, :updater]
          associations.select! { |assoc| ::Wms::Location.reflections.key?(assoc.to_s) }
          query = query.includes(*associations) unless associations.empty?
        rescue
        end
        
        @q = query.ransack(params[:q])
        @locations = @q.result()
        
        if params[:list]
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @locations.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @locations.size, 
            size: per_page, 
            page: page 
          }
        else
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @locations = @locations.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @locations.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@location) ? @location.base_info : @location.attributes 
        }
      end

      def create
        @location = ::Wms::Location.new(location_params)
        @location.user_id = @current_user.id if @location.respond_to?(:user_id) && @location.user_id.nil?

        if @location.save
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Wms/location#{@location.name rescue @location.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@location) ? @location.base_info : @location.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Wms/location失败: #{@location.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @location.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      def update
        location_params_hash = location_params.to_h
        location_params_hash[:updater_id] = @current_user.id if @location.respond_to?(:updater_id)
        if @location.update(location_params_hash)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@location) ? @location.base_info : @location.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/location修改#{@location.name rescue @location.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Wms/location修改#{@location.name rescue @location.id} 失败: #{@location.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @location.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Wms/location删除#{@location.name rescue @location.id}成功")
        @location.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      def import
        if params[:tag] == "import_template"
          column_names = ::Wms::Location.respond_to?(:imp_exp_hander) ? ::Wms::Location.imp_exp_hander : ::Wms::Location.column_names
          i18n_column_names = ::Wms::Location.respond_to?(:il8n_imp_exp_hander) ? ::Wms::Location.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Wms/location模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Wms::Location.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Wms/location预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:locations].blank?

          ::Wms::Location.transaction do
            params[:locations].each do |location_params|
              location = ::Wms::Location.new(location_params.to_unsafe_h)
              if location.save
                results[:success] += 1
                data << location
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Wms/location#{location.name rescue location.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: location_params, errors: location.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Wms/location#{location_params[:name]}失败: #{location.errors.full_messages.join(",")}")
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

          ::Wms::Location.transaction do
            selected_ids.each do |location_id|
              location = ::Wms::Location.find_by(id: location_id)
              if location
                if location.update(update_params)
                  results[:success] += 1
                  data << location
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Wms/location#{location.name rescue location.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: location_id, errors: location.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/location#{location.name rescue location.id}失败: #{location.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: location_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Wms/location失败: 记录ID #{location_id} 不存在")
              end
            end
          end

        when "delete"
          ::Wms::Location.transaction do
            params[:ids].each do |location_id|
              location = ::Wms::Location.find(location_id)
              if location
                location.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Wms/location#{location.name rescue location.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: location_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Wms/location失败: 记录ID #{location_id} 不存在")
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
        def set_location
          @location = ::Wms::Location.find(params[:id]) rescue nil
          if @location.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def location_params
          params.permit(:warehouse_id, :area_id, :name, :abbr, :code, :type_id, :is_active, :is_adjustment, :is_reservation, :sort, :description, :user_id, :updater_id, :py, :pinyin)
        end
        
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end
        
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @location || ::Wms::Location)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
