namespace :menu do
  desc "根据模块生成菜单信息 rails menu:generate"
  task :generate => [:environment] do
    puts "开始生成菜单..."
    
    # 定义模块配置
    module_configs = {
      base: {
        title: "基础信息",
        icon: "el-icon-warehouse",
        resources: [
          { name: "regions", title: "行政区划", path: "/base/regions" },
          { name: "properties", title: "属性", path: "/base/properties" },
        ]
      },
      inv: {
        title: "库存管理",
        icon: "el-icon-warehouse",
        resources: [
          { name: "lots", title: "批次序列号", path: "/inv/lots" },
          { name: "inventories", title: "库存", path: "/inv/inventories" },
          { name: "inventory_transactions", title: "库存流水", path: "/inv/inventory_transactions" },
          { name: "inventory_locks", title: "库存预占", path: "/inv/inventory_locks" }
        ]
      },
      wms: {
        title: "仓库管理",
        icon: "el-icon-s-shop",
        resources: [
          { name: "warehouses", title: "仓库", path: "/wms/warehouses" },
          { name: "areas", title: "库区", path: "/wms/areas" },
          { name: "locations", title: "货位", path: "/wms/locations" },
          { name: "pick_orders", title: "领料单", path: "/wms/pick_orders" },
          { name: "receive_orders", title: "入库单", path: "/wms/receive_orders" },
          { name: "return_orders", title: "退货单", path: "/wms/return_orders" },
          { name: "transfer_orders", title: "调拨单", path: "/wms/transfer_orders" },
        ]
      },
      mfg: {
        title: "生产管理",
        icon: "el-icon-s-tools",
        resources: [
          { name: "orders", title: "生产订单", path: "/mfg/orders" },
          { name: "boms", title: "物料清单", path: "/mfg/boms" },
          { name: "bom_byproducts", title: "BOM副产品", path: "/mfg/bom_byproducts" },
          { name: "bom_losses", title: "BOM损耗", path: "/mfg/bom_losses" },
          { name: "work_orders", title: "工单", path: "/mfg/work_orders" },
          { name: "work_order_losses", title: "工单损耗", path: "/mfg/work_order_losses" },
          { name: "work_order_byproducts", title: "工单副产品", path: "/mfg/work_order_byproducts" },
          { name: "disassembly_orders", title: "拆解单", path: "/mfg/disassembly_orders" },
          { name: "scrap_orders", title: "报废单", path: "/mfg/scrap_orders" }
        ]
      }
    }
    
    # 起始排序号
    base_sort = 100
    
    module_configs.each_with_index do |(module_key, config), module_index|
      module_sort = base_sort + (module_index * 100)
      
      # 检查模块菜单是否已存在
      parent_menu = Menu.find_or_initialize_by(name: "#{module_key}_module")
      
      if parent_menu.new_record?
        puts "创建模块菜单: #{config[:title]}"
        parent_menu.assign_attributes(
          path: "/#{module_key}",
          title: config[:title],
          icon: config[:icon],
          component: "/#{module_key}/index",
          menu_type: "menu",
          is_hide: false,
          is_enable: true,
          sort: module_sort,
          remark: "#{config[:title]}模块"
        )
        parent_menu.save!
      else
        puts "更新模块菜单: #{config[:title]}"
        parent_menu.update!(
          path: "/#{module_key}",
          title: config[:title],
          icon: config[:icon],
          component: "/#{module_key}/index",
          sort: module_sort
        )
      end
      
      # 创建资源子菜单
      config[:resources].each_with_index do |resource, resource_index|
        resource_sort = module_sort + (resource_index + 1)
        resource_name = "#{module_key}_#{resource[:name]}"
        
        child_menu = Menu.find_or_initialize_by(name: resource_name, parent_id: parent_menu.id)
        
        if child_menu.new_record?
          puts "  创建子菜单: #{resource[:title]}"
          child_menu.assign_attributes(
            parent_id: parent_menu.id,
            path: resource[:path],
            title: resource[:title],
            component: resource[:path],
            menu_type: "menu",
            is_hide: false,
            is_enable: true,
            sort: resource_sort,
            remark: "#{config[:title]} - #{resource[:title]}"
          )
          child_menu.save!
        else
          puts "  更新子菜单: #{resource[:title]}"
          child_menu.update!(
            path: resource[:path],
            title: resource[:title],
            component: resource[:path],
            sort: resource_sort
          )
        end
      end
    end
    
    puts "菜单生成完成！"
    puts "共生成 #{module_configs.keys.size} 个模块菜单"
    total_resources = module_configs.values.sum { |config| config[:resources].size }
    puts "共生成 #{total_resources} 个资源菜单"
  end
  
  desc "清理并重新生成菜单 rails menu:regenerate"
  task :regenerate => [:environment] do
    puts "清理现有菜单..."
    
    # 删除所有模块相关的菜单（包括子菜单）
    module_names = ["mat_module", "inv_module", "wms_module", "mfg_module"]
    module_names.each do |module_name|
      menu = Menu.find_by(name: module_name)
      if menu
        puts "删除模块菜单及其子菜单: #{menu.title}"
        # 删除所有子菜单
        menu.children.destroy_all
        # 删除父菜单
        menu.destroy
      end
    end
    
    # 额外清理：删除所有以模块名开头的子菜单（防止遗漏）
    Menu.where("name LIKE ? OR name LIKE ? OR name LIKE ? OR name LIKE ?", 
               "mat_%", "inv_%", "wms_%", "mfg_%").where.not(name: module_names).destroy_all
    
    puts "开始重新生成菜单..."
    Rake::Task["menu:generate"].invoke
  end
end
