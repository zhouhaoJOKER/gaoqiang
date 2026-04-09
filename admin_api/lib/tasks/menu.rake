namespace :menu  do
  
    desc "rails menu:import  " 
    task :import => [:environment] do

      data = File.read(Rails.root.join("tmp", "menu.json"))
      menus_json = JSON.parse(data, symbolize_names: true)
      menus =  menus_json[:data]
      # p menus
      # 
      Menu.delete_all
      menu_type = "menu"
      
      menus.each do |single|
        p single
        # Menu.import_menu(single, nil)
        p "导入菜单：#{single[:name]}"
        # 
        item = {
          name: single[:name],
          path: single[:path],
          component: single[:component],
          redirect: single[:redirect],
          menu_type: menu_type,
          icon: single[:meta][:icon],
          title: single[:meta][:title],
          is_hide: single[:meta][:isHide],
          is_link: single[:meta][:isLink],
          is_full: single[:meta][:isFull],
          is_affix: single[:meta][:isAffix],
          is_keep_alive: single[:meta][:isKeepAlive],
          active_menu: single[:meta][:activeMenu],
          sort: single[:sort] || 0,
          perms: single[:perms] || '',
        }
        menu = Menu.create!(item)
        # 递归子菜单
        (single[:children]).each do |child|
          p "----导入子菜单：#{child[:name]}"

          item = {
            parent_id: menu.id,
            name: child[:name],
            path: child[:path],
            component: child[:component],
            redirect: child[:redirect],
            menu_type: menu_type,
            icon: child[:meta][:icon],
            title: child[:meta][:title],
            is_hide: child[:meta][:isHide],
            is_link: child[:meta][:isLink],
            is_full: child[:meta][:isFull],
            is_affix: child[:meta][:isAffix],
            is_keep_alive: child[:meta][:isKeepAlive],
            active_menu: child[:meta][:activeMenu],
            sort: child[:sort] || 0,
            perms: single[:perms] || '',
          }
          Menu.create!(item)  rescue nil
        end if single[:children].present?
        
        #
      end
      
    end
    
end
