# frozen_string_literal: true

# TMS 运输/发货模块路由：解运单、发货计划等
namespace :tms do
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

  match "plans" => "plans#index", via: :get
  match "plans" => "plans#create", via: :post
  match "plans/:id" => "plans#update", via: :put
  match "plans/:id" => "plans#show", via: :get
  match "plans/:id" => "plans#destroy", via: :delete
  match "plans/batch_action" => "plans#batch_action", via: :post
  match "plans/import" => "plans#import", via: :post
end
