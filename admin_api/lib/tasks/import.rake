namespace :import  do
  
    desc "rails import:dep  " 
    task :dep => [:environment] do
      Department.delete_all
      file = Rails.root.join("tmp", "dep.txt")
      data  = File.read(file)
      list =  data.gsub(" ","").split("|")
      
      list.each do |single|
        arr = single.split("\t")
        Department.create(
          code: arr[0],
          name: arr[1],
          parent_code: arr[2],
        )
      end

      
      Department.all.each do |single|
        parent  = Department.find_by(code: single.parent_code) rescue ''
        if parent.present?
          p parent.name
          single.update(parent_id: parent.id)
        end
      end
    end

    desc "rails import:menu  " 
    task :menu => [:environment] do
      menus_json = [{"path": "/home/index","name": "home","component": "/home/index","icon": "HomeFilled","title": "首页","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true},{"path": "/standard/index","name": "standard","component": "/standard/index","icon": "HomeFilled","title": "集团标准体系","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true,"activeMenu": ""},{"path": "/quality/index","name": "quality","component": "/quality/index","icon": "HomeFilled","title": "质量认证","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true,"activeMenu": ""},{"path": "/intellectual-property/index","name": "intellectual-property","component": "/intellectual-property/index","icon": "HomeFilled","title": "知识产权","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true,"activeMenu": ""},{"path": "/group-knowledge/index","name": "group-knowledge","component": "/group-knowledge/index","icon": "HomeFilled","title": "组织知识库","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true,"activeMenu": ""},{"path": "/product-performance/index","name": "product-performance","component": "/product-performance/index","icon": "HomeFilled","title": "产品性能规范","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true,"activeMenu": ""},{"path": "/permission","name": "permission","redirect": "/permission/menu/index","icon": "HomeFilled","title": "权限管理","isLink": "","isHide": false,"isFull": false,"isAffix": true,"isKeepAlive": true}]

      Menu.delete_all
      menus_json.each do |single|
        p single
        p single[:name]
        data = {
          path: single[:path],  
          name: single[:name],  
          redirect: single[:redirect],  
          component: single[:component],  
          icon: single[:icon],  
          title: single[:title],  
          is_link: single[:isLink],  
          is_hide: single[:isHide],  
          is_full: single[:isFull],  
          is_affix: single[:isAffix],  
          is_keep_alive: single[:isKeepAlive],  
          active_menu: single[:activeMenu]||"",
        }
        m = Menu.create(data)
        p m.id
           
      end
      

      
    end

    desc "rails import:pm_templates - 从 tmp/pm-data-5.json 导入模板数据到 Pm::Template"
    task :pm_templates => [:environment] do
      file_path = Rails.root.join("tmp", "pm-data-5.json")
      
      unless File.exist?(file_path)
        puts "错误: 文件 #{file_path} 不存在"
        exit 1
      end

      puts "开始读取 JSON 文件..."
      file_content = File.read(file_path)
      
      # 移除 JSON 文件开头的注释行（如果有）
      file_content = file_content.gsub(/^\/\/.*$/, '').strip
      
      begin
        json_data = JSON.parse(file_content)
      rescue JSON::ParserError => e
        puts "错误: JSON 解析失败 - #{e.message}"
        exit 1
      end

      templates_data = json_data["result"]
      
      unless templates_data.is_a?(Array)
        puts "错误: JSON 文件中没有找到 'result' 数组"
        exit 1
      end

      puts "找到 #{templates_data.size} 条模板数据，开始导入..."
      
      success_count = 0
      error_count = 0
      skip_count = 0

      templates_data.each_with_index do |item, index|
        begin
          name = item["name"]
          description = item.dig("payload", "description") || ""
          logo = item.dig("payload", "logo") || ""

          # 跳过名称为空的记录
          if name.blank?
            puts "跳过第 #{index + 1} 条记录: 名称为空"
            skip_count += 1
            next
          end

          # 检查是否已存在相同名称的模板
          existing_template = ::Pm::Template.find_by(name: name)
          
          if existing_template
            # 更新已存在的模板
            existing_template.update(
              description: description,
              logo: logo
            )
            puts "更新模板: #{name} (ID: #{existing_template.id})"
            success_count += 1
          else
            # 创建新模板
            template = ::Pm::Template.create(
              name: name,
              description: description,
              logo: logo
            )
            
            if template.persisted?
              puts "创建模板: #{name} (ID: #{template.id})"
              success_count += 1
            else
              puts "创建模板失败: #{name} - #{template.errors.full_messages.join(", ")}"
              error_count += 1
            end
          end
        rescue => e
          puts "处理第 #{index + 1} 条记录时出错: #{e.message}"
          error_count += 1
        end
      end

      puts "\n导入完成!"
      puts "成功: #{success_count} 条"
      puts "失败: #{error_count} 条"
      puts "跳过: #{skip_count} 条"
      puts "总计: #{templates_data.size} 条"
    end
end
