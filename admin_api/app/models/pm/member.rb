class Pm::Member < ApplicationRecord
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :record, polymorphic: true, optional: true
    
    def base_info
        {
          id: id,
          record_type: record_type,
          record_id: record_id,
          user_id: user_id,
          name: (user.name rescue ""),
          role_id: role_id,
          joined_at: joined_at,
          created_time: created_time,
          updated_time: updated_time,
        }
    end
  
end
