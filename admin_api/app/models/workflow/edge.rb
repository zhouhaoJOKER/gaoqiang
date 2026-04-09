# frozen_string_literal: true

module Workflow
  class Edge < ApplicationRecord
    self.table_name = "workflow_edges"

    belongs_to :template, class_name: "Workflow::Template", foreign_key: :template_id

    validates :source_key, :target_key, presence: true
  end
end
