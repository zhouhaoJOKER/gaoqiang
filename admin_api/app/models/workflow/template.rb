# frozen_string_literal: true

module Workflow
  class Template < ApplicationRecord
    self.table_name = "workflow_templates"

    has_many :nodes, class_name: "Workflow::Node", foreign_key: :template_id, dependent: :destroy
    has_many :node_results, class_name: "Workflow::NodeResult", foreign_key: :template_id, dependent: :destroy
    has_many :edges, class_name: "Workflow::Edge", foreign_key: :template_id, dependent: :destroy

    validates :code, presence: true, uniqueness: true
    validates :name, presence: true

    scope :active, -> { where(is_active: true) }

    def self.default_template
      find_by(is_default: true) || active.first
    end
  end
end
