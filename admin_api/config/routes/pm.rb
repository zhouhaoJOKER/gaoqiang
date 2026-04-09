# frozen_string_literal: true

# PM 项目管理模块路由
namespace :pm do
  match "portfolios" => "portfolios#index", via: :get
  match "portfolios" => "portfolios#create", via: :post
  match "portfolios/:id" => "portfolios#update", via: :put
  match "portfolios/:id" => "portfolios#show", via: :get
  match "portfolios/:id" => "portfolios#destroy", via: :delete
  match "portfolios/batch_action" => "portfolios#batch_action", via: :post
  match "portfolios/import" => "portfolios#import", via: :post
  match "portfolios_trees" => "portfolios#company_trees", via: :get

  match "projects" => "projects#index", via: :get
  match "projects" => "projects#create", via: :post
  match "projects/:id" => "projects#update", via: :put
  match "projects/:id" => "projects#show", via: :get
  match "projects/:id" => "projects#destroy", via: :delete
  match "projects/batch_action" => "projects#batch_action", via: :post
  match "projects/import" => "projects#import", via: :post
  match "projects_trees" => "projects#company_trees", via: :get

  match "templates" => "templates#index", via: :get
  match "templates" => "templates#create", via: :post
  match "templates/:id" => "templates#update", via: :put
  match "templates/:id" => "templates#show", via: :get
  match "templates/:id" => "templates#destroy", via: :delete
  match "templates/batch_action" => "templates#batch_action", via: :post
  match "templates/import" => "templates#import", via: :post

  match "stages" => "stages#index", via: :get
  match "stages" => "stages#create", via: :post
  match "stages/:id" => "stages#update", via: :put
  match "stages/:id" => "stages#show", via: :get
  match "stages/:id" => "stages#destroy", via: :delete
  match "stages/batch_action" => "stages#batch_action", via: :post
  match "stages/import" => "stages#import", via: :post

  match "tasks" => "tasks#index", via: :get
  match "tasks" => "tasks#create", via: :post
  match "tasks/:id" => "tasks#update", via: :put
  match "tasks/:id" => "tasks#show", via: :get
  match "tasks/:id" => "tasks#destroy", via: :delete
  match "tasks/batch_action" => "tasks#batch_action", via: :post
  match "tasks/import" => "tasks#import", via: :post

  match "timesheets" => "timesheets#index", via: :get
  match "timesheets" => "timesheets#create", via: :post
  match "timesheets/:id" => "timesheets#update", via: :put
  match "timesheets/:id" => "timesheets#destroy", via: :delete

  match "files" => "files#index", via: :get
  match "files" => "files#create", via: :post
  match "files/:id" => "files#update", via: :put
  match "files/:id" => "files#show", via: :get
  match "files/:id" => "files#destroy", via: :delete
  match "files/batch_action" => "files#batch_action", via: :post
  match "files/import" => "files#import", via: :post
  match "files_trees" => "files#files_trees", via: :get
  match "files/upload" => "files#upload", via: :post

  match "documents" => "documents#index", via: :get
  match "documents" => "documents#create", via: :post
  match "documents/:id" => "documents#update", via: :put
  match "documents/:id" => "documents#show", via: :get
  match "documents/:id" => "documents#destroy", via: :delete
  match "documents/batch_action" => "documents#batch_action", via: :post
  match "documents/import" => "documents#import", via: :post
  match "documents_trees" => "documents#documents_trees", via: :get
end
