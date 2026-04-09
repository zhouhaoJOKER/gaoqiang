class Pm::Task < ApplicationRecord
    has_ancestry

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..256 },  presence: true

    validates_uniqueness_of :name, :scope => :parent_id

    # before_create :genereate_parent_code
    before_save :gen_py
    # after_create :generate_default_stages

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :executor, class_name: "User", foreign_key: "executor_id", optional: true
    
    # belongs_to :company, class_name: "Company", optional: true
    belongs_to :project, class_name: "Pm::Project", optional: true
    belongs_to :stage, class_name: "Pm::Stage", foreign_key: "stage_id", optional: true, counter_cache: :task_count

    belongs_to :parent, class_name: "Pm::Task", optional: true
    belongs_to :portfolio, class_name: "Pm::Portfolio", foreign_key: "portfolio_id", optional: true

    belongs_to :status, class_name: "Property", optional: true, foreign_key: "status_id", optional: true
    belongs_to :category, class_name: "Property", foreign_key: "category_id", optional: true
    belongs_to :priority, class_name: "Property", foreign_key: "priority_id", optional: true
    
    has_many :members, class_name: "Pm::Member", as: :record
    # belongs_to :members, class_name: "Pm::Member", through: :record_id, foreign_key: "id", optional: true

    has_many :children, class_name: "Pm::Task", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string


    def base_info
      {
        id: id,
        project_id: project_id,
        project_name: (project.name rescue ""),
        stage_id: stage_id,
        stage_name: (stage.name rescue ""),
        category_id: category_id,
        category_name: (category.name rescue ""),
        status_id: status_id,
        status_name: (status.name rescue ""),
        parent_id: parent_id,
        parent_name: (parent.name rescue ""),
        name: name,
        py: py,
        priority_id: priority_id,
        priority_name: (priority.name rescue ""),
        sort: sort,
        labels: labels,
        custom_fields: custom_fields,
        start_at: start_at,
        due_at: due_at,
        done_at: done_at,
        is_star: is_star,
        is_public: is_public,
        is_done: is_done,
        executor_id: executor_id,
        executor_name: (executor.name rescue ""),
        user_id: user_id,
        user_name: (user.name rescue ""),
        updater_id: updater_id,
        updater_name: (updater.name rescue ""),
        description: description,
        plan_time: plan_time,
        real_time: real_time,
        progress: progress,
        ancestry: ancestry,
        created_at: created_at,
        updated_at: updated_at,
        created_time: created_time,
        updated_time: updated_time,
        members: members.map{|m| m.base_info  rescue {} },
      }
    end
end
