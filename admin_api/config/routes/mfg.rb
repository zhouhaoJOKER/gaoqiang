# frozen_string_literal: true

# MFG 生产制造模块路由
namespace :mfg do
  match "orders" => "orders#index", via: :get
  match "orders" => "orders#create", via: :post
  match "orders/:id" => "orders#update", via: :put
  match "orders/:id" => "orders#show", via: :get
  match "orders/:id" => "orders#destroy", via: :delete
  match "orders/batch_action" => "orders#batch_action", via: :post
  match "orders/import" => "orders#import", via: :post

  match "order_lines" => "order_lines#index", via: :get
  match "order_lines" => "order_lines#create", via: :post
  match "order_lines/:id" => "order_lines#update", via: :put
  match "order_lines/:id" => "order_lines#show", via: :get
  match "order_lines/:id" => "order_lines#destroy", via: :delete
  match "order_lines/batch_action" => "order_lines#batch_action", via: :post
  match "order_lines/import" => "order_lines#import", via: :post

  match "boms" => "boms#index", via: :get
  match "boms" => "boms#create", via: :post
  match "boms/:id" => "boms#update", via: :put
  match "boms/:id" => "boms#show", via: :get
  match "boms/:id" => "boms#destroy", via: :delete
  match "boms/batch_action" => "boms#batch_action", via: :post
  match "boms/import" => "boms#import", via: :post

  match "bom_lines" => "bom_lines#index", via: :get
  match "bom_lines" => "bom_lines#create", via: :post
  match "bom_lines/:id" => "bom_lines#update", via: :put
  match "bom_lines/:id" => "bom_lines#show", via: :get
  match "bom_lines/:id" => "bom_lines#destroy", via: :delete
  match "bom_lines/batch_action" => "bom_lines#batch_action", via: :post
  match "bom_lines/import" => "bom_lines#import", via: :post

  match "bom_byproducts" => "bom_byproducts#index", via: :get
  match "bom_byproducts" => "bom_byproducts#create", via: :post
  match "bom_byproducts/:id" => "bom_byproducts#update", via: :put
  match "bom_byproducts/:id" => "bom_byproducts#show", via: :get
  match "bom_byproducts/:id" => "bom_byproducts#destroy", via: :delete
  match "bom_byproducts/batch_action" => "bom_byproducts#batch_action", via: :post
  match "bom_byproducts/import" => "bom_byproducts#import", via: :post

  match "bom_losses" => "bom_losses#index", via: :get
  match "bom_losses" => "bom_losses#create", via: :post
  match "bom_losses/:id" => "bom_losses#update", via: :put
  match "bom_losses/:id" => "bom_losses#show", via: :get
  match "bom_losses/:id" => "bom_losses#destroy", via: :delete
  match "bom_losses/batch_action" => "bom_losses#batch_action", via: :post
  match "bom_losses/import" => "bom_losses#import", via: :post

  match "work_orders" => "work_orders#index", via: :get
  match "work_orders" => "work_orders#create", via: :post
  match "work_orders/:id" => "work_orders#update", via: :put
  match "work_orders/:id" => "work_orders#show", via: :get
  match "work_orders/:id" => "work_orders#destroy", via: :delete
  match "work_orders/batch_action" => "work_orders#batch_action", via: :post
  match "work_orders/import" => "work_orders#import", via: :post

  match "work_order_losses" => "work_order_losses#index", via: :get
  match "work_order_losses" => "work_order_losses#create", via: :post
  match "work_order_losses/:id" => "work_order_losses#update", via: :put
  match "work_order_losses/:id" => "work_order_losses#show", via: :get
  match "work_order_losses/:id" => "work_order_losses#destroy", via: :delete
  match "work_order_losses/batch_action" => "work_order_losses#batch_action", via: :post
  match "work_order_losses/import" => "work_order_losses#import", via: :post

  match "disassembly_orders" => "disassembly_orders#index", via: :get
  match "disassembly_orders" => "disassembly_orders#create", via: :post
  match "disassembly_orders/:id" => "disassembly_orders#update", via: :put
  match "disassembly_orders/:id" => "disassembly_orders#show", via: :get
  match "disassembly_orders/:id" => "disassembly_orders#destroy", via: :delete
  match "disassembly_orders/batch_action" => "disassembly_orders#batch_action", via: :post
  match "disassembly_orders/import" => "disassembly_orders#import", via: :post

  match "scrap_orders" => "scrap_orders#index", via: :get
  match "scrap_orders" => "scrap_orders#create", via: :post
  match "scrap_orders/:id" => "scrap_orders#update", via: :put
  match "scrap_orders/:id" => "scrap_orders#show", via: :get
  match "scrap_orders/:id" => "scrap_orders#destroy", via: :delete
  match "scrap_orders/batch_action" => "scrap_orders#batch_action", via: :post
  match "scrap_orders/import" => "scrap_orders#import", via: :post

  match "work_order_byproducts" => "work_order_byproducts#index", via: :get
  match "work_order_byproducts" => "work_order_byproducts#create", via: :post
  match "work_order_byproducts/:id" => "work_order_byproducts#update", via: :put
  match "work_order_byproducts/:id" => "work_order_byproducts#show", via: :get
  match "work_order_byproducts/:id" => "work_order_byproducts#destroy", via: :delete
  match "work_order_byproducts/batch_action" => "work_order_byproducts#batch_action", via: :post
  match "work_order_byproducts/import" => "work_order_byproducts#import", via: :post

  # 计划排产与包装
  match "plans" => "plans#index", via: :get
  match "plans" => "plans#create", via: :post
  match "plans/:id" => "plans#update", via: :put
  match "plans/:id" => "plans#show", via: :get
  match "plans/:id" => "plans#destroy", via: :delete
  match "plans/batch_action" => "plans#batch_action", via: :post
  match "plans/import" => "plans#import", via: :post

  match "plan_lines" => "plan_lines#index", via: :get
  match "plan_lines" => "plan_lines#create", via: :post
  match "plan_lines/:id" => "plan_lines#update", via: :put
  match "plan_lines/:id" => "plan_lines#show", via: :get
  match "plan_lines/:id" => "plan_lines#destroy", via: :delete
  match "plan_lines/batch_action" => "plan_lines#batch_action", via: :post
  match "plan_lines/import" => "plan_lines#import", via: :post

  match "batchings" => "batchings#index", via: :get
  match "batchings" => "batchings#create", via: :post
  match "batchings/:id" => "batchings#update", via: :put
  match "batchings/:id" => "batchings#show", via: :get
  match "batchings/:id" => "batchings#destroy", via: :delete
  match "batchings/batch_action" => "batchings#batch_action", via: :post
  match "batchings/import" => "batchings#import", via: :post

  match "batching_lines" => "batching_lines#index", via: :get
  match "batching_lines" => "batching_lines#create", via: :post
  match "batching_lines/:id" => "batching_lines#update", via: :put
  match "batching_lines/:id" => "batching_lines#show", via: :get
  match "batching_lines/:id" => "batching_lines#destroy", via: :delete
  match "batching_lines/batch_action" => "batching_lines#batch_action", via: :post
  match "batching_lines/import" => "batching_lines#import", via: :post

  match "oprates" => "oprates#index", via: :get
  match "oprates" => "oprates#create", via: :post
  match "oprates/:id" => "oprates#update", via: :put
  match "oprates/:id" => "oprates#show", via: :get
  match "oprates/:id" => "oprates#destroy", via: :delete
  match "oprates/batch_action" => "oprates#batch_action", via: :post
  match "oprates/import" => "oprates#import", via: :post

  match "oprate_lines" => "oprate_lines#index", via: :get
  match "oprate_lines" => "oprate_lines#create", via: :post
  match "oprate_lines/:id" => "oprate_lines#update", via: :put
  match "oprate_lines/:id" => "oprate_lines#show", via: :get
  match "oprate_lines/:id" => "oprate_lines#destroy", via: :delete
  match "oprate_lines/batch_action" => "oprate_lines#batch_action", via: :post
  match "oprate_lines/import" => "oprate_lines#import", via: :post

  match "oprate_step_lines" => "oprate_step_lines#index", via: :get
  match "oprate_step_lines" => "oprate_step_lines#create", via: :post
  match "oprate_step_lines/:id" => "oprate_step_lines#update", via: :put
  match "oprate_step_lines/:id" => "oprate_step_lines#show", via: :get
  match "oprate_step_lines/:id" => "oprate_step_lines#destroy", via: :delete
  match "oprate_step_lines/batch_action" => "oprate_step_lines#batch_action", via: :post
  match "oprate_step_lines/import" => "oprate_step_lines#import", via: :post

  match "pkg_handovers" => "pkg_handovers#index", via: :get
  match "pkg_handovers" => "pkg_handovers#create", via: :post
  match "pkg_handovers/:id" => "pkg_handovers#update", via: :put
  match "pkg_handovers/:id" => "pkg_handovers#show", via: :get
  match "pkg_handovers/:id" => "pkg_handovers#destroy", via: :delete
  match "pkg_handovers/batch_action" => "pkg_handovers#batch_action", via: :post
  match "pkg_handovers/import" => "pkg_handovers#import", via: :post

  match "pkg_lines" => "pkg_lines#index", via: :get
  match "pkg_lines" => "pkg_lines#create", via: :post
  match "pkg_lines/:id" => "pkg_lines#update", via: :put
  match "pkg_lines/:id" => "pkg_lines#show", via: :get
  match "pkg_lines/:id" => "pkg_lines#destroy", via: :delete
  match "pkg_lines/batch_action" => "pkg_lines#batch_action", via: :post
  match "pkg_lines/import" => "pkg_lines#import", via: :post

  match "actuals" => "actuals#index", via: :get
  match "actuals" => "actuals#create", via: :post
  match "actuals/:id" => "actuals#update", via: :put
  match "actuals/:id" => "actuals#show", via: :get
  match "actuals/:id" => "actuals#destroy", via: :delete
  match "actuals/batch_action" => "actuals#batch_action", via: :post
  match "actuals/import" => "actuals#import", via: :post
end
