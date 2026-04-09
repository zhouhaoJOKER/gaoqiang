# frozen_string_literal: true

# CRM 模块路由：客户、合同、交接单、报价、开票等
namespace :crm do
  match "clients" => "clients#index", via: :get
  match "clients" => "clients#create", via: :post
  match "clients/:id" => "clients#update", via: :put
  match "clients/:id" => "clients#show", via: :get
  match "clients/:id" => "clients#destroy", via: :delete
  match "clients/batch_action" => "clients#batch_action", via: :post
  match "clients/import" => "clients#import", via: :post

  match "contacts" => "contacts#index", via: :get
  match "contacts" => "contacts#create", via: :post
  match "contacts/:id" => "contacts#update", via: :put
  match "contacts/:id" => "contacts#show", via: :get
  match "contacts/:id" => "contacts#destroy", via: :delete
  match "contacts/batch_action" => "contacts#batch_action", via: :post
  match "contacts/import" => "contacts#import", via: :post

  match "addresses" => "addresses#index", via: :get
  match "addresses" => "addresses#create", via: :post
  match "addresses/:id" => "addresses#update", via: :put
  match "addresses/:id" => "addresses#show", via: :get
  match "addresses/:id" => "addresses#destroy", via: :delete
  match "addresses/batch_action" => "addresses#batch_action", via: :post
  match "addresses/import" => "addresses#import", via: :post


  match "handovers" => "handovers#index", via: :get
  match "handovers" => "handovers#create", via: :post
  match "handovers/:id" => "handovers#update", via: :put
  match "handovers/:id" => "handovers#show", via: :get
  match "handovers/:id" => "handovers#destroy", via: :delete
  match "handovers/batch_action" => "handovers#batch_action", via: :post
  match "handovers/import" => "handovers#import", via: :post

  match "handover_lines" => "handover_lines#index", via: :get
  match "handover_lines" => "handover_lines#create", via: :post
  match "handover_lines/:id" => "handover_lines#update", via: :put
  match "handover_lines/:id" => "handover_lines#show", via: :get
  match "handover_lines/:id" => "handover_lines#destroy", via: :delete
  match "handover_lines/batch_action" => "handover_lines#batch_action", via: :post
  match "handover_lines/import" => "handover_lines#import", via: :post

  match "quotations" => "quotations#index", via: :get
  match "quotations" => "quotations#create", via: :post
  match "quotations/:id" => "quotations#update", via: :put
  match "quotations/:id" => "quotations#show", via: :get
  match "quotations/:id" => "quotations#destroy", via: :delete
  match "quotations/batch_action" => "quotations#batch_action", via: :post
  match "quotations/import" => "quotations#import", via: :post

  match "quotation_lines" => "quotation_lines#index", via: :get
  match "quotation_lines" => "quotation_lines#create", via: :post
  match "quotation_lines/:id" => "quotation_lines#update", via: :put
  match "quotation_lines/:id" => "quotation_lines#show", via: :get
  match "quotation_lines/:id" => "quotation_lines#destroy", via: :delete
  match "quotation_lines/batch_action" => "quotation_lines#batch_action", via: :post
  match "quotation_lines/import" => "quotation_lines#import", via: :post

  match "spec_items" => "spec_items#index", via: :get
  match "spec_items" => "spec_items#create", via: :post
  match "spec_items/:id" => "spec_items#update", via: :put
  match "spec_items/:id" => "spec_items#show", via: :get
  match "spec_items/:id" => "spec_items#destroy", via: :delete
  match "spec_items/batch_action" => "spec_items#batch_action", via: :post
  match "spec_items/import" => "spec_items#import", via: :post

  match "invoices" => "invoices#index", via: :get
  match "invoices" => "invoices#create", via: :post
  match "invoices/:id" => "invoices#update", via: :put
  match "invoices/:id" => "invoices#show", via: :get
  match "invoices/:id" => "invoices#destroy", via: :delete
  match "invoices/batch_action" => "invoices#batch_action", via: :post
  match "invoices/import" => "invoices#import", via: :post

  # 预购单管理 + 转订单
  match "pre_orders" => "pre_orders#index", via: :get
  match "pre_orders/:id" => "pre_orders#show", via: :get
  match "pre_orders/:id" => "pre_orders#update", via: :put
  match "pre_orders/:id" => "pre_orders#destroy", via: :delete
  match "pre_orders/:id/convert_to_order" => "pre_orders#convert_to_order", via: :post

  # CRM 订单 + 订单明细
  match "orders" => "orders#index", via: :get
  match "orders" => "orders#create", via: :post
  match "orders/:id" => "orders#show", via: :get
  match "orders/:id" => "orders#update", via: :put
  match "orders/:id" => "orders#destroy", via: :delete
  match "orders/batch_action" => "orders#batch_action", via: :post

  match "order_lines/internal_tracking" => "order_lines#internal_tracking", via: :get

  match "order_lines" => "order_lines#index", via: :get
  match "order_lines" => "order_lines#create", via: :post
  match "order_lines/:id" => "order_lines#show", via: :get
  match "order_lines/:id" => "order_lines#update", via: :put
  match "order_lines/:id" => "order_lines#destroy", via: :delete
  match "order_lines/batch_action" => "order_lines#batch_action", via: :post
end
