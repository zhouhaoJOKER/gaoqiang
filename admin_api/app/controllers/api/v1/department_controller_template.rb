module Api
  module V1
    class DepartmentControllerTemplate < BaseController
      before_action :set_department, only: [ :show, :update, :destroy ]

      # GET /api/v1/departments
      def index
        if params[:list]
          gen_log(@current_user.id, @current_ip, params[:action], 1, "访问部门列表")
          @departments = Department.includes(:company, :parent, :children).where(parent_id: nil)
          render json: { code: 200, success: 1, msg: "ok", data: @departments.map { |e|e.base_info }, total: @departments.size, size: per_page, page: page }
        else
          departments = Department.includes(:company, :parent, :children).order("code desc")
          @q = departments.ransack(params[:q]).result()
          @departments = @q.paginate(page: params[:current], per_page: params[:size])
          gen_log(@current_user.id, @current_ip, params[:action], 1, "访问部门列表")
          render json: { code: 200, success: 1, msg: "ok", data: @departments.map { |e|e.base_info }, total: @q.size, size: per_page, current: params[:current] }
        end
      end

      # GET /api/v1/departments/1
      def show
        render json: { code: 200, success: 1, msg: "ok", data: @department.base_info }
      end

      # POST /api/v1/departments
      def create
        department_params[:parent_id] = "" if params["parent_id"] == 0
        @department = Department.new(department_params)

        @department.id = "" if params["id"] == 0
        if @department.save
          @department.update_columns(parent_id: params["parent_id"]) if params["parent_id"].present? and params["parent_id"] != 0
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加部门#{department_params[:name]}成功")
          render json: { code: 200, success: 1, msg: t("create_success"), data: @department.base_info }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加部门#{department_params[:name]}失败")
          render json: { code: 500, success: 0, msg: @department.errors.full_messages.join(","), data: "" }
        end
      end

      # PATCH/PUT /api/v1/departments/1
      def update
        if @department.update(department_params)
          @department.update_columns(parent_id: params["parent_id"]) if params["parent_id"].present? # fix ancestry not update parent_id
          render json: { code: 200, success: 1, msg: "ok", data: @department.base_info }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "部门修改#{@department.name} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "部门修改#{@department.name} 失败")
          render json: { code: 500, success: 0, msg: @department.errors.full_messages.join(","), data: "" }
        end
      end

      # DELETE /api/v1/departments/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "部门删除#{@department.name}成功")
        @department.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/department_trees
      def department_trees
        departments = Department.where(parent_id: nil).includes(:company, :parent, :children).order("code desc")
        @q = departments.ransack(params[:q])
        @departments = @q.result().paginate(page: params[:page], per_page: per_page)
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问部门列表")
        render json: { code: 200, success: 1, msg: "ok", data: @departments.map { |e|e.tree_info }, meta: { total: @departments.total_entries, per_page: per_page, page: page } }
      end

      # 导入部门
      def import
        if params[:tag] == "import_template"
          column_names = Department.imp_exp_hander
          i18n_column_names = Department.il8n_imp_exp_hander
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入部门模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
          attachment = Attachment.create(
            file: params[:file],
            user_id: @current_user.id,
            name: "导入#{Department.table_name}",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入部门预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作部门
      # POST /api/v1/departments/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:departments].blank?

          Department.transaction do
            params[:departments].each do |dept_params|
              department = Department.new(dept_params.to_unsafe_h)
              if department.save
                department.update_columns(parent_id: dept_params[:parent_id]) if dept_params[:parent_id].present?
                results[:success] += 1
                data << department.base_info
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增部门#{department.name}成功")
              else
                results[:failed] += 1
                results[:errors] << { params: dept_params, errors: department.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增部门#{dept_params[:name]}失败: #{department.errors.full_messages.join(",")}")
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

          return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results }
          Department.transaction do
            selected_ids.each do |dept_id|
              department = Department.find_by(id: dept_id)
              if department
                if department.update(update_params)
                  # 处理parent_id更新（如果需要）
                  department.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present?
                  results[:success] += 1
                  data << department.base_info
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改部门#{department.name}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: dept_id, errors: department.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改部门#{department.name}失败: #{department.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: dept_id, errors: [ "部门不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改部门失败: 部门ID #{dept_id} 不存在")
              end
            end
          end

        when "delete"
          Department.transaction do
            params[:ids].each do |dept_id|
              department = Department.find(dept_id)
              if department
                department.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除部门#{department.name}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: dept_id, errors: [ "部门不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除部门失败: 部门ID #{dept_id} 不存在")
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
        def set_department
          @department = Department.find(params[:id]) rescue nil
          if @department.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def department_params
          params.permit(:code, :name, :parent_id, :parent_code, :status, :sort, :manager_id, :remark, :created_at, :updated_at, :company_id)
        end
    end
  end
end
