class Pm::Timesheet < ApplicationRecord
    # kind:integer project_id:integer:index date:date task_id:integer:index time:decimal user_id:integer updater_id:integer
    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    
    # belongs_to :company, class_name: "Company", optional: true
    belongs_to :project, class_name: "Pm::Project", optional: true
    belongs_to :task, class_name: "Pm::Task", optional: true

    # enum kind: { plan: 0, real: 1}
    after_create :sum_time_after_create
    after_update :sum_time_after_update
    after_destroy :sum_time_after_destroy

    def is_plan?
        kind == 0
    end
    
    
    def sum_time_after_create
        return unless task_id.present? && time.present?
        
        time_field = is_plan? ? "plan_time" : "real_time"
        ::Pm::Task.where(id: task_id).update_all("#{time_field} = COALESCE(#{time_field}, 0) + #{time}")
    end
    
    def sum_time_after_update
        return unless task_id.present? && saved_change_to_time?
        
        time_field = is_plan? ? "plan_time" : "real_time"
        time_diff = time - time_before_last_save
        
        ::Pm::Task.where(id: task_id).update_all("#{time_field} = COALESCE(#{time_field}, 0) + #{time_diff}") if time_diff != 0
    end
    
    def sum_time_after_destroy
        return unless task_id.present? && time.present?
        
        time_field = is_plan? ? "plan_time" : "real_time"
        ::Pm::Task.where(id: task_id).update_all("#{time_field} = COALESCE(#{time_field}, 0) - #{time}")
    end


    def base_info
        {
            id: id,
            kind: kind,
            project_id: project_id,
            project_name: (project.name rescue ''),
            task_id: task_id,
            task_name: (task.name rescue ''),
            date: date,
            time: time,
            user_id: user_id,
            user_name: (user.name rescue ''),
            updater_name: (updater.name rescue ''),
            updater_id: updater_id,
            description: description,
            created_at: created_at,
            updated_at: updated_at
        }
        
    end
    
end
