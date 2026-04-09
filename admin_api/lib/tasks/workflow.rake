# frozen_string_literal: true

namespace :workflow do
  desc "初始化流程模板数据（基于 workflow_data_example.json）"
  task seed: :environment do
    load Rails.root.join("db", "seeds", "workflow.rb")
  end
end
