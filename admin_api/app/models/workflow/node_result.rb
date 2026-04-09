# frozen_string_literal: true

module Workflow
  class NodeResult < ApplicationRecord
    self.table_name = "workflow_node_results"

    belongs_to :template, class_name: "Workflow::Template", foreign_key: :template_id

    validates :node_key, :result_value, presence: true
    validates :result_value, uniqueness: { scope: [:template_id, :node_key] }
  end
end
