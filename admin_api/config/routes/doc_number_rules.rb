# 单号规则配置及生成接口（generate/preview 须在 :id 之前）
match "doc_number_rules/generate" => "doc_number_rules#generate", via: :post
match "doc_number_rules/preview" => "doc_number_rules#preview", via: :get
match "doc_number_rules" => "doc_number_rules#index", via: :get
match "doc_number_rules" => "doc_number_rules#create", via: :post
match "doc_number_rules/:id" => "doc_number_rules#update", via: :put
match "doc_number_rules/:id" => "doc_number_rules#show", via: :get
match "doc_number_rules/:id" => "doc_number_rules#destroy", via: :delete
match "doc_number_rules/batch_action" => "doc_number_rules#batch_action", via: :post
match "doc_number_rules/import" => "doc_number_rules#import", via: :post
