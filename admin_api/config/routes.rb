Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
 
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/jobs"


  #持续请求
  match "api/v1/ping"  => "home#ping", via: :get
  match "api/v1/version"  => "home#version", via: :get

  match "api/v1/site_info"  => "home#site_info", via: :get
  # match "/api/user/list"  => "home#user_list", via: :get

  

  namespace :api do
    namespace :v2 do
      match "todo"  => "home#todo", via: :post

      # 在线预购（仅需 PREORDER_API_TOKEN，不要求登录）
      namespace :mat do
        match "properties" => "properties#index", via: :get
        match "products" => "products#index", via: :get
        match "pre_orders" => "pre_orders#create", via: :post
      end
    end

    namespace :v1 do
      match "api/common/upload/wangeditor"  => "upload#wangeditor", via: :post
      #访问操作日志
      match "test"  => "settings#test", via: :post

      #访问日志
      match "logs"  => "logs#index", via: :get

      # namespace :users do

      #属性相关 role
      match "properties"  => "properties#index", via: :get
      match "properties"  => "properties#create", via: :post
      match "properties/:id"  => "properties#update", via: :put
      match "properties/:id"  => "properties#show", via: :get
      match "properties/:id"  => "properties#destroy", via: :delete
      match "properties/batch_action"  => "properties#batch_action", via: :post
      match "properties/import"  => "properties#import", via: :post

      # 省市区
      match "provinces" => "provinces#index", via: :get
      match "provinces" => "provinces#create", via: :post
      match "provinces/:id" => "provinces#show", via: :get
      match "provinces/:id" => "provinces#update", via: :put
      match "provinces/:id" => "provinces#destroy", via: :delete

      match "cities" => "cities#index", via: :get
      match "cities" => "cities#create", via: :post
      match "cities/:id" => "cities#show", via: :get
      match "cities/:id" => "cities#update", via: :put
      match "cities/:id" => "cities#destroy", via: :delete

      match "counties" => "counties#index", via: :get
      match "counties" => "counties#create", via: :post
      match "counties/:id" => "counties#show", via: :get
      match "counties/:id" => "counties#update", via: :put
      match "counties/:id" => "counties#destroy", via: :delete

      #登录系统
      match "login"  => "sessions#login", via: :post
      match "register"  => "sessions#register", via: :post
      match "forgot_password"  => "sessions#forgot_password", via: :post
      match "reset_password"  => "sessions#reset_password", via: :post
      match "confirm"  => "sessions#confirm", via: :post
      match "logout"  => "sessions#logout", via: :post
      match "sms_send"  => "sessions#sms_send", via: :post
      match "sms_login"  => "sessions#sms_login", via: :post

      match "info"  => "users#info", via: :get
      match "menu"  => "menus#menu", via: :get
      match "upload"  => "upload#upload", via: :post
      match "basic_upload"  => "upload#basic_upload", via: :post
      match "upload_test"  => "upload#upload_test", via: :post

      match "users/search"  => "users#search", via: :get

      match "users"  => "users#index", via: :get
      match "users"  => "users#create", via: :post
      match "users/:id"  => "users#update", via: :put
      match "users/:id"  => "users#show", via: :get
      match "users/:id"  => "users#delete", via: :delete
      match "users/export"  => "users#export", via: :get
      match "users/import"  => "users#import", via: :post
      match "users/change_password"  => "users#change_password", via: :post
      match "users/reset_password"  => "users#reset_password", via: :post
      match "users/batch_action"  => "users#batch_action", via: :post
      match "users/import"  => "users#import", via: :post
      match "users/send_reset_password_email"  => "users#send_reset_password_email", via: :post

      #角色相关 role
      match "roles"  => "roles#index", via: :get
      match "roles"  => "roles#create", via: :post
      match "roles/:id"  => "roles#update", via: :put
      match "roles/:id"  => "roles#show", via: :get
      match "roles/:id"  => "roles#delete", via: :delete
      match "roles/batch_action"  => "roles#batch_action", via: :post
      match "roles/import"  => "roles#import", via: :post

      #角色相关 menu
      match "menus"  => "menus#index", via: :get
      match "menus"  => "menus#create", via: :post
      match "menus/:id"  => "menus#update", via: :put
      match "menus/:id"  => "menus#show", via: :get
      match "menus/:id"  => "menus#delete", via: :delete
      match "menus/batch_action"  => "menus#batch_action", via: :post
      match "menus/import"  => "menus#import", via: :post

      #部门相关 department
      match "departments"  => "departments#index", via: :get
      match "departments"  => "departments#create", via: :post
      match "departments/:id"  => "departments#update", via: :put
      match "departments/:id"  => "departments#show", via: :get
      match "departments/:id"  => "departments#delete", via: :delete
      match "departments/batch_action"  => "departments#batch_action", via: :post
      match "departments/import"  => "departments#import", via: :post
      match "departments_trees"  => "departments#departments_trees", via: :get
      


      #配置相关 setting
      match "settings"  => "settings#index", via: :get
      match "settings"  => "settings#create", via: :post
      match "settings/:id"  => "settings#update", via: :put
      match "settings/:id"  => "settings#show", via: :get
      match "settings/:id"  => "settings#delete", via: :delete
      match "settings/batch_action"  => "settings#batch_action", via: :post
      match "settings/import"  => "settings#import", via: :post

      #公司相关 companies
      match "companies"  => "companies#index", via: :get
      match "companies"  => "companies#create", via: :post
      match "companies/:id"  => "companies#update", via: :put
      match "companies/:id"  => "companies#show", via: :get
      match "companies/:id"  => "companies#destroy", via: :delete
      match "companies/batch_action"  => "companies#batch_action", via: :post
      match "companies/import"  => "companies#import", via: :post
      match "company_trees"  => "companies#company_trees", via: :get

      # 单号规则配置（各模块单独配置）
      draw :doc_number_rules

      # 各业务模块路由（按 mfg rms inv iqc pm tms mat pur wms crm qa 拆分）
      draw :workflow
      draw :crm
      draw :fm
      draw :pur
      draw :rms
      draw :iqc
      draw :mfg
      draw :wms
      draw :tms
      draw :mat
      draw :inv
      draw :pm
      draw :qa

      #活动 activities
      match "activities"  => "activities#index", via: :get
      match "activities"  => "activities#create", via: :post
      match "activities/:id"  => "activities#update", via: :put
      match "activities/:id"  => "activities#show", via: :get
      match "activities/:id"  => "activities#destroy", via: :delete
      match "activities/batch_action"  => "activities#batch_action", via: :post
      match "activities/import"  => "activities#import", via: :post
      
      #配置相关 config
      match "configs"  => "configs#configs", via: :get
      match "create_config"  => "configs#create_config", via: :post
      match "delete_config"  => "configs#delete_config", via: :post
      match "update_config"  => "configs#update_config", via: :post


      #目录文件相关 node
      match "nodes"  => "nodes#nodes", via: :get
      match "create_node"  => "nodes#create_node", via: :post
      match "delete_node"  => "nodes#delete_node", via: :post
      match "update_node"  => "nodes#update_node", via: :post

      match "node_trees"  => "nodes#node_trees", via: :get
      match "node_files"  => "nodes#node_files", via: :get
      
    end
  end
  # 获取当前用户权限
  match "api/v1/roles/me"  => "api/v1/sessions#my_role", via: :get

  # match "api/v1/settings/:var" => "api/v1/settings#index", via: :get # 获取配置
  # match "api/v1/settings/:var" => "api/v1/settings#update", via: :post # 更新配置

  match "api/v1/settings"  => "api/v1/settings#index", via: :get
 

  match "api/v1/permissions"  => "api/v1/permissions#permissions", via: :get

  #权限新建
  match "api/v1/create_permission"  => "api/v1/permissions#create_permission", via: :post

  #权限删除
  match "api/v1/delete_permission"  => "api/v1/permissions#delete_permission", via: :post

  #权限修改
  match "api/v1/update_permission"  => "api/v1/permissions#update_permission", via: :post

  #访问角色类别
  match "api/v1/role_category"  => "api/v1/settings#role_category", via: :get

  #访问角色
  match "api/v1/roles"  => "api/v1/roles#roles", via: :get

  #角色新建
  match "api/v1/create_role"  => "api/v1/roles#create_role", via: :post

  #角色删除
  match "api/v1/delete_role"  => "api/v1/roles#delete_role", via: :post

  #角色修改
  match "api/v1/update_role"  => "api/v1/roles#update_role", via: :post


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  #
  namespace :admin do
    resource :settings
  end

  # match "/(*path)" => "home#not_find", via: [:post, :get]

end
