# frozen_string_literal: true

# WMS 仓储模块路由
namespace :wms do
  match "pick_orders" => "pick_orders#index", via: :get
  match "pick_orders" => "pick_orders#create", via: :post
  match "pick_orders/:id" => "pick_orders#update", via: :put
  match "pick_orders/:id" => "pick_orders#show", via: :get
  match "pick_orders/:id" => "pick_orders#destroy", via: :delete
  match "pick_orders/batch_action" => "pick_orders#batch_action", via: :post
  match "pick_orders/import" => "pick_orders#import", via: :post

  match "pick_order_lines" => "pick_order_lines#index", via: :get
  match "pick_order_lines" => "pick_order_lines#create", via: :post
  match "pick_order_lines/:id" => "pick_order_lines#update", via: :put
  match "pick_order_lines/:id" => "pick_order_lines#show", via: :get
  match "pick_order_lines/:id" => "pick_order_lines#destroy", via: :delete
  match "pick_order_lines/batch_action" => "pick_order_lines#batch_action", via: :post
  match "pick_order_lines/import" => "pick_order_lines#import", via: :post

  match "receive_orders" => "receive_orders#index", via: :get
  match "receive_orders" => "receive_orders#create", via: :post
  match "receive_orders/:id" => "receive_orders#update", via: :put
  match "receive_orders/:id" => "receive_orders#show", via: :get
  match "receive_orders/:id" => "receive_orders#destroy", via: :delete
  match "receive_orders/batch_action" => "receive_orders#batch_action", via: :post
  match "receive_orders/import" => "receive_orders#import", via: :post

  match "receive_order_lines" => "receive_order_lines#index", via: :get
  match "receive_order_lines" => "receive_order_lines#create", via: :post
  match "receive_order_lines/:id" => "receive_order_lines#update", via: :put
  match "receive_order_lines/:id" => "receive_order_lines#show", via: :get
  match "receive_order_lines/:id" => "receive_order_lines#destroy", via: :delete
  match "receive_order_lines/batch_action" => "receive_order_lines#batch_action", via: :post
  match "receive_order_lines/import" => "receive_order_lines#import", via: :post

  match "return_orders" => "return_orders#index", via: :get
  match "return_orders" => "return_orders#create", via: :post
  match "return_orders/:id" => "return_orders#update", via: :put
  match "return_orders/:id" => "return_orders#show", via: :get
  match "return_orders/:id" => "return_orders#destroy", via: :delete
  match "return_orders/batch_action" => "return_orders#batch_action", via: :post
  match "return_orders/import" => "return_orders#import", via: :post

  match "return_order_lines" => "return_order_lines#index", via: :get
  match "return_order_lines" => "return_order_lines#create", via: :post
  match "return_order_lines/:id" => "return_order_lines#update", via: :put
  match "return_order_lines/:id" => "return_order_lines#show", via: :get
  match "return_order_lines/:id" => "return_order_lines#destroy", via: :delete
  match "return_order_lines/batch_action" => "return_order_lines#batch_action", via: :post
  match "return_order_lines/import" => "return_order_lines#import", via: :post

  match "transfer_orders" => "transfer_orders#index", via: :get
  match "transfer_orders" => "transfer_orders#create", via: :post
  match "transfer_orders/:id" => "transfer_orders#update", via: :put
  match "transfer_orders/:id" => "transfer_orders#show", via: :get
  match "transfer_orders/:id" => "transfer_orders#destroy", via: :delete
  match "transfer_orders/batch_action" => "transfer_orders#batch_action", via: :post
  match "transfer_orders/import" => "transfer_orders#import", via: :post

  match "transfer_order_lines" => "transfer_order_lines#index", via: :get
  match "transfer_order_lines" => "transfer_order_lines#create", via: :post
  match "transfer_order_lines/:id" => "transfer_order_lines#update", via: :put
  match "transfer_order_lines/:id" => "transfer_order_lines#show", via: :get
  match "transfer_order_lines/:id" => "transfer_order_lines#destroy", via: :delete
  match "transfer_order_lines/batch_action" => "transfer_order_lines#batch_action", via: :post
  match "transfer_order_lines/import" => "transfer_order_lines#import", via: :post

  match "warehouses" => "warehouses#index", via: :get
  match "warehouses" => "warehouses#create", via: :post
  match "warehouses/:id" => "warehouses#update", via: :put
  match "warehouses/:id" => "warehouses#show", via: :get
  match "warehouses/:id" => "warehouses#destroy", via: :delete
  match "warehouses/batch_action" => "warehouses#batch_action", via: :post
  match "warehouses/import" => "warehouses#import", via: :post

  match "areas" => "areas#index", via: :get
  match "areas" => "areas#create", via: :post
  match "areas/:id" => "areas#update", via: :put
  match "areas/:id" => "areas#show", via: :get
  match "areas/:id" => "areas#destroy", via: :delete
  match "areas/batch_action" => "areas#batch_action", via: :post
  match "areas/import" => "areas#import", via: :post

  match "locations" => "locations#index", via: :get
  match "locations" => "locations#create", via: :post
  match "locations/:id" => "locations#update", via: :put
  match "locations/:id" => "locations#show", via: :get
  match "locations/:id" => "locations#destroy", via: :delete
  match "locations/batch_action" => "locations#batch_action", via: :post
  match "locations/import" => "locations#import", via: :post

  match "notices" => "notices#index", via: :get
  match "notices" => "notices#create", via: :post
  match "notices/:id" => "notices#update", via: :put
  match "notices/:id" => "notices#show", via: :get
  match "notices/:id" => "notices#destroy", via: :delete
  match "notices/batch_action" => "notices#batch_action", via: :post
  match "notices/import" => "notices#import", via: :post

  match "notice_lines" => "notice_lines#index", via: :get
  match "notice_lines" => "notice_lines#create", via: :post
  match "notice_lines/:id" => "notice_lines#update", via: :put
  match "notice_lines/:id" => "notice_lines#show", via: :get
  match "notice_lines/:id" => "notice_lines#destroy", via: :delete
  match "notice_lines/batch_action" => "notice_lines#batch_action", via: :post
  match "notice_lines/import" => "notice_lines#import", via: :post
end
