# frozen_string_literal: true

namespace :wgd do
  match "orders" => "orders#index", via: :get
  match "orders" => "orders#create", via: :post
  match "orders/batch_action" => "orders#batch_action", via: :post
  match "orders/:id" => "orders#show", via: :get
  match "orders/:id" => "orders#update", via: :put
  match "orders/:id" => "orders#destroy", via: :delete

  match "order_lines" => "order_lines#index", via: :get
  match "order_lines" => "order_lines#create", via: :post
  match "order_lines/batch_action" => "order_lines#batch_action", via: :post
  match "order_lines/:id" => "order_lines#show", via: :get
  match "order_lines/:id" => "order_lines#update", via: :put
  match "order_lines/:id" => "order_lines#destroy", via: :delete
end
