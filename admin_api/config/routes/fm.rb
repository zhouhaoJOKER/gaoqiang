# FM 模块路由：合同、款项单
namespace :fm do
    match "contracts" => "contracts#index", via: :get
    match "contracts" => "contracts#create", via: :post
    match "contracts/:id" => "contracts#update", via: :put
    match "contracts/:id" => "contracts#show", via: :get
    match "contracts/:id" => "contracts#destroy", via: :delete
    match "contracts/:id/workflow_logs" => "contracts#workflow_logs", via: :get
    match "contracts/:id/workflow_logs" => "contracts#create_workflow_log", via: :post
    match "contracts/:id/workflow_states" => "contracts#workflow_states", via: :get
    match "contracts/:id/workflow_states" => "contracts#update_workflow_states", via: :put
    match "contracts/:id/workflow_definition" => "contracts#workflow_definition", via: :get
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