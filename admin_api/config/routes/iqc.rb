# frozen_string_literal: true

# IQC 来料/过程检验模块路由：原料检验、半成品检测、包装抽样等
namespace :iqc do
  match "raws" => "raws#index", via: :get
  match "raws" => "raws#create", via: :post
  match "raws/:id" => "raws#update", via: :put
  match "raws/:id" => "raws#show", via: :get
  match "raws/:id" => "raws#destroy", via: :delete
  match "raws/batch_action" => "raws#batch_action", via: :post
  match "raws/import" => "raws#import", via: :post

  match "raw_lines" => "raw_lines#index", via: :get
  match "raw_lines" => "raw_lines#create", via: :post
  match "raw_lines/:id" => "raw_lines#update", via: :put
  match "raw_lines/:id" => "raw_lines#show", via: :get
  match "raw_lines/:id" => "raw_lines#destroy", via: :delete
  match "raw_lines/batch_action" => "raw_lines#batch_action", via: :post
  match "raw_lines/import" => "raw_lines#import", via: :post

  match "fdfs" => "fdfs#index", via: :get
  match "fdfs" => "fdfs#create", via: :post
  match "fdfs/:id" => "fdfs#update", via: :put
  match "fdfs/:id" => "fdfs#show", via: :get
  match "fdfs/:id" => "fdfs#destroy", via: :delete
  match "fdfs/batch_action" => "fdfs#batch_action", via: :post
  match "fdfs/import" => "fdfs#import", via: :post

  match "fdf_lines" => "fdf_lines#index", via: :get
  match "fdf_lines" => "fdf_lines#create", via: :post
  match "fdf_lines/:id" => "fdf_lines#update", via: :put
  match "fdf_lines/:id" => "fdf_lines#show", via: :get
  match "fdf_lines/:id" => "fdf_lines#destroy", via: :delete
  match "fdf_lines/batch_action" => "fdf_lines#batch_action", via: :post
  match "fdf_lines/import" => "fdf_lines#import", via: :post

  match "ldfs" => "ldfs#index", via: :get
  match "ldfs" => "ldfs#create", via: :post
  match "ldfs/:id" => "ldfs#update", via: :put
  match "ldfs/:id" => "ldfs#show", via: :get
  match "ldfs/:id" => "ldfs#destroy", via: :delete
  match "ldfs/batch_action" => "ldfs#batch_action", via: :post
  match "ldfs/import" => "ldfs#import", via: :post

  match "ldf_lines" => "ldf_lines#index", via: :get
  match "ldf_lines" => "ldf_lines#create", via: :post
  match "ldf_lines/:id" => "ldf_lines#update", via: :put
  match "ldf_lines/:id" => "ldf_lines#show", via: :get
  match "ldf_lines/:id" => "ldf_lines#destroy", via: :delete
  match "ldf_lines/batch_action" => "ldf_lines#batch_action", via: :post
  match "ldf_lines/import" => "ldf_lines#import", via: :post

  match "pkgs" => "pkgs#index", via: :get
  match "pkgs" => "pkgs#create", via: :post
  match "pkgs/:id" => "pkgs#update", via: :put
  match "pkgs/:id" => "pkgs#show", via: :get
  match "pkgs/:id" => "pkgs#destroy", via: :delete
  match "pkgs/batch_action" => "pkgs#batch_action", via: :post
  match "pkgs/import" => "pkgs#import", via: :post
end
