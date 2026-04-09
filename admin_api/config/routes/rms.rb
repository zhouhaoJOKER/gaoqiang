# frozen_string_literal: true

# RMS 配方/交接模块路由：配方交接单、交接明细、合同、采购明细等
namespace :rms do
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

  match "handover_contracts" => "handover_contracts#index", via: :get
  match "handover_contracts" => "handover_contracts#create", via: :post
  match "handover_contracts/:id" => "handover_contracts#update", via: :put
  match "handover_contracts/:id" => "handover_contracts#show", via: :get
  match "handover_contracts/:id" => "handover_contracts#destroy", via: :delete
  match "handover_contracts/batch_action" => "handover_contracts#batch_action", via: :post
  match "handover_contracts/import" => "handover_contracts#import", via: :post

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
