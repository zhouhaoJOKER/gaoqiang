module Api
  module V1
    class Iqc::FdfsController < BaseController
      before_action :set_fdfs, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/fdfs
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Iqc/fdfs列表")
        
        # 基础查询
        query = ::Iqc::Fdf.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Iqc::Fdf.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @fdfs = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @fdfs = @fdfs.where(parent_id: nil) if ::Iqc::Fdf.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @fdfs.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @fdfs.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @fdfs = @fdfs.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @fdfs.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/fdfs/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@fdfs) ? @fdfs.base_info : @fdfs.attributes 
        }
      end

      # POST /api/v1/fdfs
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Iqc::Fdf.column_names.include?("parent_id")
          fdfs_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @fdfs = ::Iqc::Fdf.new(fdfs_params)

        if @fdfs.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Iqc::Fdf.column_names.include?("parent_id") && params["parent_id"] != 0
            @fdfs.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Iqc/fdfs#{@fdfs.name rescue @fdfs.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@fdfs) ? @fdfs.base_info : @fdfs.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Iqc/fdfs失败: #{@fdfs.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @fdfs.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/fdfs/1
      def update
        if @fdfs.update(fdfs_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Iqc::Fdf.column_names.include?("parent_id")
            @fdfs.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@fdfs) ? @fdfs.base_info : @fdfs.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Iqc/fdfs修改#{@fdfs.name rescue @fdfs.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Iqc/fdfs修改#{@fdfs.name rescue @fdfs.id} 失败: #{@fdfs.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @fdfs.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/fdfs/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Iqc/fdfs删除#{@fdfs.name rescue @fdfs.id}成功")
        @fdfs.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/fdfs_trees
      def fdfs_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Iqc/fdfs树状列表")
        
        # 基础查询
        query = ::Iqc::Fdf.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Iqc::Fdf.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Iqc::Fdf.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @fdfs = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @fdfs.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @fdfs.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/fdfs/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Iqc::Fdf.respond_to?(:imp_exp_hander) ? ::Iqc::Fdf.imp_exp_hander : ::Iqc::Fdf.column_names
          i18n_column_names = ::Iqc::Fdf.respond_to?(:il8n_imp_exp_hander) ? ::Iqc::Fdf.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Iqc/fdfs模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Iqc::Fdf.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Iqc/fdfs预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/fdfs/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:fdfs].blank?

          ::Iqc::Fdf.transaction do
            params[:fdfs].each do |fdfs_params|
              fdfs = ::Iqc::Fdf.new(fdfs_params.to_unsafe_h)
              if fdfs.save
                fdfs.update_columns(parent_id: fdfs_params[:parent_id]) if fdfs_params[:parent_id].present? && ::Iqc::Fdf.column_names.include?("parent_id")
                results[:success] += 1
                data << fdfs
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Iqc/fdfs#{fdfs.name rescue fdfs.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: fdfs_params, errors: fdfs.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Iqc/fdfs#{fdfs_params[:name]}失败: #{fdfs.errors.full_messages.join(",")}")
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

          ::Iqc::Fdf.transaction do
            selected_ids.each do |fdfs_id|
              fdfs = ::Iqc::Fdf.find_by(id: fdfs_id)
              if fdfs
                if fdfs.update(update_params)
                  # 处理parent_id更新（如果需要）
                  fdfs.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Iqc::Fdf.column_names.include?("parent_id")
                  results[:success] += 1
                  data << fdfs
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Iqc/fdfs#{fdfs.name rescue fdfs.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: fdfs_id, errors: fdfs.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Iqc/fdfs#{fdfs.name rescue fdfs.id}失败: #{fdfs.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: fdfs_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Iqc/fdfs失败: 记录ID #{fdfs_id} 不存在")
              end
            end
          end

        when "delete"
          ::Iqc::Fdf.transaction do
            params[:ids].each do |fdfs_id|
              fdfs = ::Iqc::Fdf.find(fdfs_id)
              if fdfs
                fdfs.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Iqc/fdfs#{fdfs.name rescue fdfs.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: fdfs_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Iqc/fdfs失败: 记录ID #{fdfs_id} 不存在")
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
        def set_fdfs
          @fdfs = ::Iqc::Fdf.find(params[:id]) rescue nil
          if @fdfs.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def fdfs_params
          params.permit(:contract_id, :product_id, :name, :code, :inspection_basis, :instrument_number, :customer_trademark_name, :request_inspection_date, :std_sample_1_m, :std_sample_1_x, :std_sample_1_spectrum_id, :std_sample_1_a_r_1, :std_sample_1_a_r_2, :std_sample_2_m, :std_sample_2_x, :std_sample_2_spectrum_id, :std_sample_2_a_r_1, :std_sample_2_a_r_2, :user_id, :updater_id, :py)
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
            authorize!(params[:action].to_sym, @fdfs || ::Iqc::Fdf)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
