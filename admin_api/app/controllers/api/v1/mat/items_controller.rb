module Api
  module V1
    class Mat::ItemsController < BaseController
      before_action :set_item, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/items
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/item列表")
        
        # 基础查询
        query = ::Mat::Item.order("id desc")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Item.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @items = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @items = @items.where(parent_id: nil) if ::Mat::Item.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @items.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @items.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @items = @items.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @items.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/items/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@item) ? @item.base_info : @item.attributes 
        }
      end

      # POST /api/v1/items
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mat::Item.column_names.include?("parent_id")
          item_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        @item = ::Mat::Item.new(item_params)
        @item.user_id = @current_user.id if @item.respond_to?(:user_id) && @item.user_id.nil?

        
        if @item.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Item.column_names.include?("parent_id") && params["parent_id"] != 0
            @item.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mat/item#{@item.name rescue @item.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@item) ? @item.base_info : @item.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mat/item失败: #{@item.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @item.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/items/1
      def update
        attrs = item_params.to_h
        attrs[:updater_id] = @current_user.id if @item.respond_to?(:updater_id)
        if @item.update(attrs)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Item.column_names.include?("parent_id")
            @item.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@item) ? @item.base_info : @item.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/item修改#{@item.name rescue @item.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mat/item修改#{@item.name rescue @item.id} 失败: #{@item.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @item.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/items/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/item删除#{@item.name rescue @item.id}成功")
        @item.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/item_trees
      def item_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/item树状列表")
        
        # 基础查询
        query = ::Mat::Item.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mat::Item.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Item.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @items = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @items.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @items.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/items/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mat::Item.respond_to?(:imp_exp_hander) ? ::Mat::Item.imp_exp_hander : ::Mat::Item.column_names
          i18n_column_names = ::Mat::Item.respond_to?(:il8n_imp_exp_hander) ? ::Mat::Item.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mat/item模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mat::Item.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mat/item预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/items/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:items].blank?

          ::Mat::Item.transaction do
            params[:items].each do |item_params|
              item = ::Mat::Item.new(item_params.to_unsafe_h)
              if item.save
                item.update_columns(parent_id: item_params[:parent_id]) if item_params[:parent_id].present? && ::Mat::Item.column_names.include?("parent_id")
                results[:success] += 1
                data << item
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mat/item#{item.name rescue item.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: item_params, errors: item.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mat/item#{item_params[:name]}失败: #{item.errors.full_messages.join(",")}")
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

          ::Mat::Item.transaction do
            selected_ids.each do |item_id|
              item = ::Mat::Item.find_by(id: item_id)
              if item
                if item.update(update_params)
                  # 处理parent_id更新（如果需要）
                  item.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mat::Item.column_names.include?("parent_id")
                  results[:success] += 1
                  data << item
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mat/item#{item.name rescue item.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: item_id, errors: item.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/item#{item.name rescue item.id}失败: #{item.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: item_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/item失败: 记录ID #{item_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mat::Item.transaction do
            params[:ids].each do |item_id|
              item = ::Mat::Item.find(item_id)
              if item
                item.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mat/item#{item.name rescue item.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: item_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mat/item失败: 记录ID #{item_id} 不存在")
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
        def set_item
          @item = ::Mat::Item.find(params[:id]) rescue nil
          if @item.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def item_params
          permitted = [:labels, :custom_fields, :user_id, :updater_id, :company_id, :name, :name_en, :logo, :code, :py, :pinyin, :barcode, :type_id, :category_id, :price, :cost_price, :market_price, :description, :uom_id, :uom_po_id, :sale_tax_id, :purchase_tax_id, :is_sale, :is_purchase, :is_manufacture, :is_stock, :is_active, :track_inventory, :track_inventory_type, :product_id, :value_id, :sku, :weight, :volume, :length, :width, :height, :qty_onhand, :qty_available, :qty_incoming, :qty_outgoing]
          params[:item].present? ? params.require(:item).permit(permitted) : params.permit(permitted)
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
            authorize!(params[:action].to_sym, @item || ::Mat::Item)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
