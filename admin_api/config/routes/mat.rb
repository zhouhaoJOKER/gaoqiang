# frozen_string_literal: true

# MAT 物料/主数据模块路由
namespace :mat do
  match "products" => "products#index", via: :get
  match "products" => "products#create", via: :post
  match "products/:id" => "products#update", via: :put
  match "products/:id" => "products#show", via: :get
  match "products/:id" => "products#destroy", via: :delete
  match "products/batch_action" => "products#batch_action", via: :post
  match "products/import" => "products#import", via: :post

  match "items" => "items#index", via: :get
  match "items" => "items#create", via: :post
  match "items/:id" => "items#update", via: :put
  match "items/:id" => "items#show", via: :get
  match "items/:id" => "items#destroy", via: :delete
  match "items/batch_action" => "items#batch_action", via: :post
  match "items/import" => "items#import", via: :post

  match "combos" => "combos#index", via: :get
  match "combos" => "combos#create", via: :post
  match "combos/:id" => "combos#update", via: :put
  match "combos/:id" => "combos#show", via: :get
  match "combos/:id" => "combos#destroy", via: :delete
  match "combos/batch_action" => "combos#batch_action", via: :post
  match "combos/import" => "combos#import", via: :post

  match "values" => "values#index", via: :get
  match "values" => "values#create", via: :post
  match "values/:id" => "values#update", via: :put
  match "values/:id" => "values#show", via: :get
  match "values/:id" => "values#destroy", via: :delete
  match "values/batch_action" => "values#batch_action", via: :post
  match "values/import" => "values#import", via: :post

  match "combo_options" => "combo_options#index", via: :get
  match "combo_options" => "combo_options#create", via: :post
  match "combo_options/:id" => "combo_options#update", via: :put
  match "combo_options/:id" => "combo_options#show", via: :get
  match "combo_options/:id" => "combo_options#destroy", via: :delete
  match "combo_options/batch_action" => "combo_options#batch_action", via: :post
  match "combo_options/import" => "combo_options#import", via: :post

  match "attributes" => "attributes#index", via: :get
  match "attributes" => "attributes#create", via: :post
  match "attributes/:id" => "attributes#update", via: :put
  match "attributes/:id" => "attributes#show", via: :get
  match "attributes/:id" => "attributes#destroy", via: :delete
  match "attributes/batch_action" => "attributes#batch_action", via: :post
  match "attributes/import" => "attributes#import", via: :post

  match "attribute_lines" => "attribute_lines#index", via: :get
  match "attribute_lines" => "attribute_lines#create", via: :post
  match "attribute_lines/:id" => "attribute_lines#update", via: :put
  match "attribute_lines/:id" => "attribute_lines#show", via: :get
  match "attribute_lines/:id" => "attribute_lines#destroy", via: :delete
  match "attribute_lines/batch_action" => "attribute_lines#batch_action", via: :post
  match "attribute_lines/import" => "attribute_lines#import", via: :post

  match "suppliers" => "suppliers#index", via: :get
  match "suppliers" => "suppliers#create", via: :post
  match "suppliers/:id" => "suppliers#update", via: :put
  match "suppliers/:id" => "suppliers#show", via: :get
  match "suppliers/:id" => "suppliers#destroy", via: :delete
  match "suppliers/batch_action" => "suppliers#batch_action", via: :post
  match "suppliers/import" => "suppliers#import", via: :post
end
