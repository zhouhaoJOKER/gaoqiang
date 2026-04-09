# frozen_string_literal: true

module Workflow
  class Node < ApplicationRecord
    self.table_name = "workflow_nodes"

    belongs_to :template, class_name: "Workflow::Template", foreign_key: :template_id

    validates :key, presence: true, uniqueness: { scope: :template_id }
    validates :label, presence: true
  end
end
