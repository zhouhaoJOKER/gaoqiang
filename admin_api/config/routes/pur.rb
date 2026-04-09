# frozen_string_literal: true

# PUR 采购模块路由：供应商、联系人、采购合同、采购明细等
namespace :pur do
  match "suppliers" => "suppliers#index", via: :get
  match "suppliers" => "suppliers#create", via: :post
  match "suppliers/:id" => "suppliers#update", via: :put
  match "suppliers/:id" => "suppliers#show", via: :get
  match "suppliers/:id" => "suppliers#destroy", via: :delete
  match "suppliers/batch_action" => "suppliers#batch_action", via: :post
  match "suppliers/import" => "suppliers#import", via: :post

  match "contacts" => "contacts#index", via: :get
  match "contacts" => "contacts#create", via: :post
  match "contacts/:id" => "contacts#update", via: :put
  match "contacts/:id" => "contacts#show", via: :get
  match "contacts/:id" => "contacts#destroy", via: :delete
  match "contacts/batch_action" => "contacts#batch_action", via: :post
  match "contacts/import" => "contacts#import", via: :post

  match "contracts" => "contracts#index", via: :get
  match "contracts" => "contracts#create", via: :post
  match "contracts/:id" => "contracts#update", via: :put
  match "contracts/:id" => "contracts#show", via: :get
  match "contracts/:id" => "contracts#destroy", via: :delete
  match "contracts/batch_action" => "contracts#batch_action", via: :post
  match "contracts/import" => "contracts#import", via: :post

  match "collections" => "collections#index", via: :get
  match "collections" => "collections#create", via: :post
  match "collections/:id" => "collections#update", via: :put
  match "collections/:id" => "collections#show", via: :get
  match "collections/:id" => "collections#destroy", via: :delete
  match "collections/batch_action" => "collections#batch_action", via: :post
  match "collections/import" => "collections#import", via: :post
end
