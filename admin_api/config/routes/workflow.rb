# 流程模块路由（无 base 前缀）
namespace :workflow do
  match "templates" => "templates#index", via: :get
  match "templates" => "templates#create", via: :post
  match "templates/:id" => "templates#show", via: :get
  match "templates/:id" => "templates#update", via: :put
  match "templates/:id" => "templates#destroy", via: :delete
  match "templates/:id/nodes" => "templates#nodes", via: :get
  match "templates/:id/nodes/:key" => "templates#update_node", via: :put
  match "templates/:id/edges" => "templates#edges", via: :get
  match "templates/:id/edges" => "templates#create_edge", via: :post
  match "templates/:id/edges/:source_key/:target_key" => "templates#destroy_edge", via: :delete
end
