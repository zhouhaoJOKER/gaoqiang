# frozen_string_literal: true

# INV 库存模块路由
namespace :inv do
  match "lots" => "lots#index", via: :get
  match "lots" => "lots#create", via: :post
  match "lots/:id" => "lots#update", via: :put
  match "lots/:id" => "lots#show", via: :get
  match "lots/:id" => "lots#destroy", via: :delete
  match "lots/batch_action" => "lots#batch_action", via: :post
  match "lots/import" => "lots#import", via: :post

  match "inventories" => "inventories#index", via: :get
  match "inventories" => "inventories#create", via: :post
  match "inventories/:id" => "inventories#update", via: :put
  match "inventories/:id" => "inventories#show", via: :get
  match "inventories/:id" => "inventories#destroy", via: :delete
  match "inventories/batch_action" => "inventories#batch_action", via: :post
  match "inventories/import" => "inventories#import", via: :post

  match "inventory_transactions" => "inventory_transactions#index", via: :get
  match "inventory_transactions" => "inventory_transactions#create", via: :post
  match "inventory_transactions/:id" => "inventory_transactions#update", via: :put
  match "inventory_transactions/:id" => "inventory_transactions#show", via: :get
  match "inventory_transactions/:id" => "inventory_transactions#destroy", via: :delete
  match "inventory_transactions/batch_action" => "inventory_transactions#batch_action", via: :post
  match "inventory_transactions/import" => "inventory_transactions#import", via: :post

  match "inventory_locks" => "inventory_locks#index", via: :get
  match "inventory_locks" => "inventory_locks#create", via: :post
  match "inventory_locks/:id" => "inventory_locks#update", via: :put
  match "inventory_locks/:id" => "inventory_locks#show", via: :get
  match "inventory_locks/:id" => "inventory_locks#destroy", via: :delete
  match "inventory_locks/batch_action" => "inventory_locks#batch_action", via: :post
  match "inventory_locks/import" => "inventory_locks#import", via: :post
end
