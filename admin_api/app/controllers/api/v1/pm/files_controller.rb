module Api
  module V1
    class Pm::FilesController < BaseController
      before_action :set_file, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      def upload
        @file = ::Pm::File.new(
          project_id: params[:project_id] ||'',
          parent_id: params[:parent_id] || '',
          kind: params[:kind] || '',
          user_id: @current_user.id,
          file: params[:file],
          name: params[:file].original_filename,
          content_type: params[:file].content_type,
          file_size: params[:file].size,
        )
        if @file.save
          # 处理父子关系（如果存在）
          @file.update_columns(parent_id: params["parent_id"]) if params["parent_id"].present?
          gen_log(@current_user.id, @current_ip, "upload_file", 1, "上传文件#{@file.name}成功")
          
          # 设置 ActiveStorage URL 选项
          ActiveStorage::Current.url_options = { host: request.base_url }
          
          render json: { code: 200, success: 1, msg: "success", data: {
            id: @file.id,
            name: @file.name,
            url: url_for(@file.file),
            # byte_size: @file.byte_size
          } }
        else
          gen_log(@current_user.id, @current_ip, "upload_file", 0, "上传文件失败: #{@file.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @file.errors.full_messages.join(","), data: "" }
        end
      end
      

      # GET /api/v1/files
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问项目列表")

        # 基础查询
        query = ::Pm::File.order("id desc")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children, :project, :user, :updater, :file ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::File.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索功能
        @q = query.ransack(params[:q])
        @files = @q.result()

        if params[:list]
          # 列表模式，只返回顶层数据
          @files = @files.where(parent_id: nil) if ::Pm::File.column_names.include?("parent_id")
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @files.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @files.size,
            size: per_page,
            page: page
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @files = @files.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @files.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size,
            size: per_page_num,
            page: page_num
          }
        end
      end

      # GET /api/v1/files/1
      def show
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: model_has_base_info?(@file) ? @file.base_info : @file.attributes
        }
      end

      # POST /api/v1/files
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Pm::File.column_names.include?("parent_id")
          file_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end

        @file = ::Pm::File.new(file_params)
        # @file.user_id = current_user.id rescue ''

        if @file.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present?
            @file.update_columns(parent_id: params["parent_id"])
          end
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加项目#{@file.name rescue @file.id}成功")
          render json: {
            code: 200,
            success: 1,
            msg: t("create_success"),
            data: model_has_base_info?(@file) ? @file.base_info : @file.attributes
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加项目失败: #{@file.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @file.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # PATCH/PUT /api/v1/files/1
      def update
        update_params = file_params.to_h
        update_params[:updater_id] = @current_user.id
        if @file.update(update_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::File.column_names.include?("parent_id")
            @file.update_columns(parent_id: params["parent_id"])
          end
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: model_has_base_info?(@file) ? @file.base_info : @file.attributes
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "项目修改#{@file.name rescue @file.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "项目修改#{@file.name rescue @file.id} 失败: #{@file.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @file.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # DELETE /api/v1/files/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "项目删除#{@file.name rescue @file.id}成功")
        @file.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/files_trees
      def files_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问项目树状列表")

        # 基础查询
        query = ::Pm::File.order("id desc")

        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Pm::File.column_names.include?("parent_id")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::File.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索和分页
        @q = query.ransack(params[:q])
        @files = @q.result().paginate(page: params[:page], per_page: per_page)

        # 渲染结果
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @files.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) },
          meta: {
            total: @files.total_entries,
            per_page: per_page,
            page: page
          }
        }
      end

      # 导入功能
      # post api/v1/files/import
      def import
        if params[:tag] == "import_file"
          column_names = ::Pm::File.respond_to?(:imp_exp_hander) ? ::Pm::File.imp_exp_hander : ::Pm::File.column_names
          i18n_column_names = ::Pm::File.respond_to?(:il8n_imp_exp_hander) ? ::Pm::File.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_file", 1, "下载导入项目项目成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Pm::File.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入项目预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/files/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:files].blank?

          ::Pm::File.transaction do
            params[:files].each do |file_params|
              file = ::Pm::File.new(file_params.to_unsafe_h)
              if file.save
                file.update_columns(parent_id: file_params[:parent_id]) if file_params[:parent_id].present? && ::Pm::File.column_names.include?("parent_id")
                results[:success] += 1
                data << file
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增项目#{file.name rescue file.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: file_params, errors: file.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增项目#{file_params[:name]}失败: #{file.errors.full_messages.join(",")}")
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

          ::Pm::File.transaction do
            selected_ids.each do |file_id|
              file = ::Pm::File.find_by(id: file_id)
              if file
                if file.update(update_params)
                  # 处理parent_id更新（如果需要）
                  file.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Pm::File.column_names.include?("parent_id")
                  results[:success] += 1
                  data << file
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改项目#{file.name rescue file.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: file_id, errors: file.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改项目#{file.name rescue file.id}失败: #{file.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: file_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改项目失败: 记录ID #{file_id} 不存在")
              end
            end
          end

        when "delete"
          ::Pm::File.transaction do
            params[:ids].each do |file_id|
              file = ::Pm::File.find(file_id)
              if file
                file.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除项目#{file.name rescue file.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: file_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除项目失败: 记录ID #{file_id} 不存在")
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
        def set_file
          @file = ::Pm::File.find(params[:id]) rescue nil
          if @file.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def file_params
          params.permit(:project_id, :parent_id, :py, :name, :file_size, :color, :user_id, :updater_id, :file_count, :is_public, :kind, :ancestry)
        end

        # 辅助方法：检查模型是否有base_info方法
        def model_has_base_info?(model)
          model.respond_to?(:base_info)
        end

        # 辅助方法：检查模型是否有tree_info方法
        def model_has_tree_info?(model)
          model.respond_to?(:tree_info)
        end

        # 权限校验方法
        def check_authorize
          begin
            authorize!(params[:action].to_sym, @file || ::Pm::File)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
