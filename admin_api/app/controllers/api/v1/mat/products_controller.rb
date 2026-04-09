module Api
  module V1
    class Mat::ProductsController < BaseController
      before_action :set_product, only: [:show, :update, :destroy]
      before_action :check_authorize

      # GET /api/v1/products
      def index
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/product列表")
        
        # 基础查询
        query = ::Mat::Product.order("id desc")

        # 二级分类筛选（与 ransack 组合）：spec_category_id 优先于 parent_category_id
        if params[:spec_category_id].present?
          query = query.where(category_id: params[:spec_category_id])
        elsif params[:parent_category_id].present?
          child_ids = ::Property.where(
            sign: "product_category",
            parent_id: params[:parent_category_id]
          ).pluck(:id)
          query = if child_ids.any?
                    query.where(category_id: child_ids)
                  else
                    query.none
                  end
        end
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :category, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Product.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索功能
        @q = query.ransack(params[:q])
        @products = @q.result()
        
        if params[:list]
          # 列表模式，只返回顶层数据
          @products = @products.where(parent_id: nil) if ::Mat::Product.column_names.include?("parent_id")
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @products.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @products.size, 
            size: per_page, 
            page: page 
          }
        else
          # 分页模式
          page_num = params[:page] || params[:current] || 1
          per_page_num = params[:per_page] || params[:size] || per_page
          @products = @products.paginate(page: page_num, per_page: per_page_num)
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: @products.map { |e| model_has_base_info?(e) ? e.base_info : e.attributes }, 
            total: @q.result().size, 
            size: per_page_num, 
            page: page_num 
          }
        end
      end

      # GET /api/v1/products/1
      def show
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: model_has_base_info?(@product) ? @product.base_info : @product.attributes 
        }
      end

      # POST /api/v1/products
      def create
        # 处理parent_id参数
        if params["parent_id"].present? && ::Mat::Product.column_names.include?("parent_id")
          product_params[:parent_id] = params["parent_id"] == 0 ? nil : params["parent_id"]
        end
        
        create_params = product_params.to_h
        
        # 处理 labels 和 custom_fields（JSON 字段，允许嵌套 hash 数组）
        if params[:product].present? && params[:product][:labels].present?
          create_params[:labels] = params[:product][:labels]
        end
        if params[:product].present? && params[:product][:custom_fields].present?
          create_params[:custom_fields] = params[:product][:custom_fields]
        end
        
        @product = ::Mat::Product.new(create_params)

        @product.user_id = @current_user.id if @product.respond_to?(:user_id) && @product.user_id.nil?
        @product.company_id = @current_user.current_company_id if @product.respond_to?(:company_id) && @product.company_id.nil?

        if @product.save
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Product.column_names.include?("parent_id") && params["parent_id"] != 0
            @product.update_columns(parent_id: params["parent_id"])
          end
          
          gen_log(@current_user.id, @current_ip, params[:action], 1, "添加Mat/product#{@product.name rescue @product.id}成功")
          render json: {
            code: 200, 
            success: 1, 
            msg: t('create_success'), 
            data: model_has_base_info?(@product) ? @product.base_info : @product.attributes 
          }
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "添加Mat/product失败: #{@product.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @product.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # PATCH/PUT /api/v1/products/1
      def update 
        update_params = product_params.to_h
        # 兜底：确保订单明细回写的 name / gram_weight 能进入更新参数
        if params[:product].is_a?(ActionController::Parameters)
          raw_product = params[:product]
          has_name = raw_product.key?(:name) || raw_product.key?("name")
          has_gram_weight = raw_product.key?(:gram_weight) || raw_product.key?("gram_weight")
          update_params[:name] = raw_product[:name] if has_name
          update_params[:gram_weight] = raw_product[:gram_weight] if has_gram_weight
        end
        update_params[:updater_id] = @current_user.id if @product.respond_to?(:updater_id)
        
        # 处理 labels 和 custom_fields（JSON 字段，允许嵌套 hash 数组）
        if params[:product].present? && params[:product][:labels].present?
          update_params[:labels] = params[:product][:labels]
        end
        if params[:product].present? && params[:product][:custom_fields].present?
          update_params[:custom_fields] = params[:product][:custom_fields]
        end
        
        if @product.update(update_params)
          # 处理父子关系（如果存在）
          if params["parent_id"].present? && ::Mat::Product.column_names.include?("parent_id")
            @product.update_columns(parent_id: params["parent_id"])
          end
          
          render json: {
            code: 200, 
            success: 1, 
            msg: "ok", 
            data: model_has_base_info?(@product) ? @product.base_info : @product.attributes 
          }
          gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/product修改#{@product.name rescue @product.id} 成功")
        else
          gen_log(@current_user.id, @current_ip, params[:action], 0, "Mat/product修改#{@product.name rescue @product.id} 失败: #{@product.errors.full_messages.join(",")}")
          render json: {
            code: 500, 
            success: 0, 
            msg: @product.errors.full_messages.join(","), 
            data: "" 
          }
        end
      end

      # DELETE /api/v1/products/1
      def destroy
        gen_log(@current_user.id, @current_ip, params[:action], 1, "Mat/product删除#{@product.name rescue @product.id}成功")
        @product.destroy
        render json: { code: 200, success: 1, msg: "success", data: "" }
      end

      # GET /api/v1/product_trees
      def product_trees
        gen_log(@current_user.id, @current_ip, params[:action], 1, "访问Mat/product树状列表")
        
        # 基础查询
        query = ::Mat::Product.order("id desc")
        
        # 仅返回顶层数据
        query = query.where(parent_id: nil) if ::Mat::Product.column_names.include?("parent_id")
        
        # 尝试包含关联（如果存在）
        begin
          associations = [:company, :parent, :children]
          # 只包含存在的关联
          associations.select! { |assoc| ::Mat::Product.reflections.key?(assoc) }
          query = query.includes(*associations) unless associations.empty?
        rescue
          # 如果关联不存在，继续执行
        end
        
        # 搜索和分页
        @q = query.ransack(params[:q])
        @products = @q.result().paginate(page: params[:page], per_page: per_page)
        
        # 渲染结果
        render json: {
          code: 200, 
          success: 1, 
          msg: "ok", 
          data: @products.map { |e| model_has_tree_info?(e) ? e.tree_info : (model_has_base_info?(e) ? e.base_info : e.attributes) }, 
          meta: { 
            total: @products.total_entries, 
            per_page: per_page, 
            page: page 
          } 
        }
      end

      # 导入功能
      # post api/v1/products/import
      def import
        if params[:tag] == "import_template"
          column_names = ::Mat::Product.respond_to?(:imp_exp_hander) ? ::Mat::Product.imp_exp_hander : ::Mat::Product.column_names
          i18n_column_names = ::Mat::Product.respond_to?(:il8n_imp_exp_hander) ? ::Mat::Product.il8n_imp_exp_hander : column_names
          data = []
          if params[:file_ext] == "csv"
            file = gen_export_csv_file(data, column_names, i18n_column_names)
          else
            file = gen_export_xlsx_file(data, column_names, i18n_column_names)
          end
          url = file.split("public/")[1]
          gen_log(@current_user.id, @current_ip, "download_template", 1, "下载导入Mat/product模板成功")
          render json: { code: 200, success: 1, msg: "success", url: url }
        elsif params[:tag] == "file"
         attachment = Attachment.create(
          file: params[:file],
          user_id: @current_user.id,
          name: "导入::Mat::Product.table_name",
          )
          file = attachment.file.path

          csv_data = CSV.read(file, skip_blanks: true)
          @il8n_headers = csv_data[0]
          @headers = headers = csv_data[1]
          data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
          @csv_data = data

          gen_log(@current_user.id, @current_ip, "import_preview", 1, "导入Mat/product预览数据成功")
          render json: { code: 200, success: 1, msg: "success", data: @csv_data }
        end
      end

      # 批量操作
      # post api/v1/products/batch_action
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
          return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:products].blank?

          ::Mat::Product.transaction do
            params[:products].each do |product_params|
              product = ::Mat::Product.new(product_params.to_unsafe_h)
              if product.save
                product.update_columns(parent_id: product_params[:parent_id]) if product_params[:parent_id].present? && ::Mat::Product.column_names.include?("parent_id")
                results[:success] += 1
                data << product
                gen_log(@current_user.id, @current_ip, "batch_create", 1, "批量新增Mat/product#{product.name rescue product.id}成功")

              else
                results[:failed] += 1
                results[:errors] << { params: product_params, errors: product.errors.full_messages }
                gen_log(@current_user.id, @current_ip, "batch_create", 0, "批量新增Mat/product#{product_params[:name]}失败: #{product.errors.full_messages.join(",")}")
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

          ::Mat::Product.transaction do
            selected_ids.each do |product_id|
              product = ::Mat::Product.find_by(id: product_id)
              if product
                if product.update(update_params)
                  # 处理parent_id更新（如果需要）
                  product.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present? && ::Mat::Product.column_names.include?("parent_id")
                  results[:success] += 1
                  data << product
                  gen_log(@current_user.id, @current_ip, "batch_update", 1, "批量修改Mat/product#{product.name rescue product.id}成功")
                else
                  results[:failed] += 1
                  results[:errors] << { id: product_id, errors: product.errors.full_messages }
                  gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/product#{product.name rescue product.id}失败: #{product.errors.full_messages.join(",")}")
                end
              else
                results[:failed] += 1
                results[:errors] << { id: product_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_update", 0, "批量修改Mat/product失败: 记录ID #{product_id} 不存在")
              end
            end
          end

        when "delete"
          ::Mat::Product.transaction do
            params[:ids].each do |product_id|
              product = ::Mat::Product.find(product_id)
              if product
                product.destroy
                results[:success] += 1
                gen_log(@current_user.id, @current_ip, "batch_delete", 1, "批量删除Mat/product#{product.name rescue product.id}成功")
              else
                results[:failed] += 1
                results[:errors] << { id: product_id, errors: [ "记录不存在" ] }
                gen_log(@current_user.id, @current_ip, "batch_delete", 0, "批量删除Mat/product失败: 记录ID #{product_id} 不存在")
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
        def set_product
          @product = ::Mat::Product.find(params[:id]) rescue nil
          if @product.nil?
            msg = "记录不存在！"
            gen_log(@current_user.id, @current_ip, params[:action], 0, "ID:#{params[:id]}, "+msg)
            render json: { code: 500, success: 0, msg: msg, data: params[:action] }
          end
        end

        def product_params
          params.require(:product).permit(
            :user_id, :updater_id, :company_id, :name, :name_en, :logo, :image_url, :code, :py, :pinyin,
            :type_id, :category_id, :material, :full_capacity, :nominal_capacity, :gram_weight, :caliber, :cap_height,
            :max_diameter, :label_size, :price, :cost_price, :market_price, :description, :uom_id, :uom_po_id,
            :sale_tax_id, :purchase_tax_id, :is_sale, :is_purchase, :is_manufacture, :is_stock, :is_active,
            :track_inventory, :track_inventory_type, :on_hand_quantity, :combo_id, labels: [], custom_fields: []
          )
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
            authorize!(params[:action].to_sym, @product || ::Mat::Product)
          rescue CanCan::AccessDenied
            render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
          end
        end
    end
  end
end
