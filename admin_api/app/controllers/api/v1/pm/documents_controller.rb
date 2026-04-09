module Api
  module V1
    class Pm::DocumentsController < BaseController
      before_action :set_document, only: [ :show, :update, :destroy ]
      before_action :check_authorize

      # GET /api/v1/documents
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问项目列表")

        # 基础查询
        query = ::Pm::Document.order("id desc")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Document.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索功能
        @q = query.ransack(params[:q])
        @documents = @q.result()

        if params[:list]
          # 列表模式，只返回顶层数据
          @documents = @documents.where(parent_id: nil) if ::Pm::Document.column_names.include?("parent_id")
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @documents.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @documents.size,
            size: per_page,
            page: page
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @documents = @documents.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: @documents.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes },
            total: @q.result().size,
            size: per_page_num,
            page: page_num
          }
        end
      end

      # GET /api/v1/documents/1
      def show
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: model_has_base_info?(@document) ? @document.base_info : @document.attributes
        }
      end

      # POST /api/v1/documents
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Pm::Document.column_names.include?("parent_id")
          document_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end

        @document = ::Pm::Document.new(document_params)
        # @document.user_id = current_user.id rescue ''

        if @document.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::Document.column_names.include?("parent_id") && params["parent_id"] != 0
            @document.update_columns(parent_id: params["parent_id"])
          end
          if params["members"].present? && @document.respond_to?(:members)
            params["members"].each do |user_id|
              member = ::Pm::Member.new(
                record_type: "::Pm::Document",
                record_id: @document.id,
                user_id: user_id,
                joined_at: Time.now,
              )
              if member.save
                gen_log(@current_user.id, @current_ip, "add_member", 1, "添加项目成员#{member.user.name rescue member.user_id}成功")
              else
                gen_log(@current_user.id, @current_ip, "add_member", 0, "添加项目成员#{member.user.name rescue member.user_id}失败: #{member.errors.full_messages.join(",")}")
              end
            end
          end


          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加项目#{@document.name rescue @document.id}成功")
          render json: {
            code: 200,
            success: 1,
            msg: t("create_success"),
            data: model_has_base_info?(@document) ? @document.base_info : @document.attributes
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加项目失败: #{@document.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @document.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # PATCH/PUT /api/v1/documents/1
      def update
        update_params = document_params.to_h
        update_params[:updater_id] = @current_user.id
        
        if @document.update!(update_params)

          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Pm::Document.column_names.include?("parent_id")
            @document.update_columns(parent_id: params["parent_id"])
          end

          # 处理项目成员同步
          # members的结构为 [ {"id" => 26, "name" => "admin1"}, {"id" => 25, "name" => "admin"} ]
          # 逻辑：如果项目成员存在记录不变，如果不存在则添加，如果传入列表中没有则删除
          if params["members"].present?
            # 获取传入的成员user_id列表（从id字段获取）
            incoming_user_ids = params["members"].map { |m| m[:id] || m["id"] }.compact.map(&:to_i)

            # 获取现有的所有成员
            existing_members = ::Pm::Member.where(
              record_type: "::Pm::Document",
              record_id: @document.id
            )

            # 处理传入的成员：添加或更新
            params["members"].each do |member_params|
              # 从id字段获取user_id（兼容symbol和string格式）
              raw_id = member_params[:id] || member_params["id"]
              next if raw_id.blank?

              user_id = raw_id.to_i
              next if user_id == 0

              member = existing_members.find_by(user_id: user_id)

              if member
                # 成员已存在，记录不变（可以在这里添加其他更新逻辑）
                # 如果需要更新joined_at，可以取消下面的注释
                # member.update_columns(joined_at: Time.now)
              else
                # 成员不存在，创建新成员
                member = ::Pm::Member.new(
                  record_type: "::Pm::Document",
                  record_id: @document.id,
                  user_id: user_id,
                  joined_at: Time.now
                )
                if member.save
                  gen_log(@current_user.id, @current_ip, "add_member", 1, "添加项目成员#{member.user.name rescue user_id}成功")
                else
                  gen_log(@current_user.id, @current_ip, "add_member", 0, "添加项目成员#{user_id}失败: #{member.errors.full_messages.join(",")}")
                end
              end
            end

            # 删除不在传入列表中的成员
            existing_members.to_a.each do |member|
              unless incoming_user_ids.include?(member.user_id)
                user_name = member.user.name rescue member.user_id
                member.destroy
                gen_log(@current_user.id, @current_ip, "remove_member", 1, "删除项目成员#{user_name}成功")
              end
            end
          end

          render json: {
            code: 200,
            success: 1,
            msg: "ok",
            data: model_has_base_info?(@document) ? @document.base_info : @document.attributes
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "项目修改#{@document.name rescue @document.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "项目修改#{@document.name rescue @document.id} 失败: #{@document.errors.full_messages.join(",")}")
          render json: {
            code: 500,
            success: 0,
            msg: @document.errors.full_messages.join(","),
            data: ""
          }
        end
      end

      # DELETE /api/v1/documents/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "项目删除#{@document.name rescue @document.id}成功")
        @document.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/documents_trees
      def documents_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问项目树状列表")

        # 基础查询
        query = ::Pm::Document.order("id desc")

        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Pm::Document.column_names.include?("parent_id")

        # 尝试包含关联（如果存在）
        begin
          associations = [ :company, :parent, :children ]
          # 只包含存在的关联
          associations.select! { |assoc| ::Pm::Document.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end

        # 搜索和分页
        @q = query.ransack(params[:q])
        @documents = @q.result().paginate(page: params[:page], per_page: per_page)

        # 渲染结果
        render json: {
          code: 200,
          success: 1,
          msg: "ok",
          data: @documents.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) },
          meta: {
            total: @documents.total_entries,
            per_page: per_page,
            page: page
          }
        }
      end

      # 导入功能
      # post api/v1/documents/import
      def import
        if params[:tag] == "import_document"
          column_names = ::Pm::Document.respond_to?(:imp_exp_hander) ? ::Pm::Document.imp_exp_hander : ::Pm::Document.column_names
          i18n_column_names = ::Pm::Document.respond_to?(:il8n_imp_exp_hander) ? ::Pm::Document.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_document", 1, "下载导入项目项目成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Pm::Document.table_name",
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
      # post api/v1/documents/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:documents].blank?

          ::Pm::Document.transaction do
            params[:documents].each do |document_params|
              document = ::Pm::Document.new(document_params.to_unsafe_h)
              if document.save
                document.update_columns(parent_id: document_params[:parent_id]) if document_params[:parent_id].present? && ::Pm::Document.column_names.include?("parent_id")
                results[:success] += 1
                data << document
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增项目#{document.name rescue document.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: document_params, errors: document.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增项目#{document_params[:name]}失败: #{document.errors.full_messages.join(",")}")
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

          ::Pm::Document.transaction do
            selected_ids.each do |document_id|
              document = ::Pm::Document.find_by(id: document_id)
              if document
                if document.update(update_params)
                  # 处理parent_id更新（如果需要）
                  document.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Pm::Document.column_names.include?("parent_id")
                  results[:success] += 1
                  data << document
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改项目#{document.name rescue document.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: document_id, errors: document.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改项目#{document.name rescue document.id}失败: #{document.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: document_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改项目失败: 记录ID #{document_id} 不存在")
              end
            end
          end

        when "delete"
          ::Pm::Document.transaction do
            params[:ids].each do |document_id|
              document = ::Pm::Document.find(document_id)
              if document
                document.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除项目#{document.name rescue document.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: document_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除项目失败: 记录ID #{document_id} 不存在")
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
        def set_document
          @document = ::Pm::Document.find(params[:id]) rescue nil
          if @document.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def document_params
          params.permit(:project_id, :parent_id, :kind, :name, :py, :content, :user_id, :updater_id, :is_public, :ancestry)
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
            authorize!(params[:action].to_sym, @document || ::Pm::Document)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
