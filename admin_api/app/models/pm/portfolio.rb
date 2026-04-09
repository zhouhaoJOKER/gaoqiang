class Pm::Portfolio < ApplicationRecord

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    validates_uniqueness_of :name #, :scope => :parent_id

    # before_create :genereate_parent_code
    before_save :gen_py

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :manager, class_name: "User", foreign_key: "manager_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :parent, class_name: "Pm::Portfolio", optional: true

    belongs_to :status, class_name: "Property", optional: true
    
    has_many :members, class_name: "Pm::Member", as: :record
    # belongs_to :members, class_name: "Pm::Member", through: :record_id, foreign_key: "id", optional: true

    has_many :children, class_name: "Pm::Portfolio", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string


  def base_info
      {
        id: id,
        code: code,
        name: name,
        status_id: status_id,
        status_name: (status.name rescue ""),
        start_date: start_date,
        end_date: end_date,
        is_star: is_star,
        manager_id: manager_id,
        manager_name: (manager.name rescue ""),
        description: description,
        degree: degree,
        labels: labels,
        custom_fields: custom_fields,
        user_id: user_id,
        updater_id: updater_id,
        company_id: company_id,
        user_name: (user.name rescue ""),
        updater_name: (updater.name rescue ""),
        created_time: created_time,
        updated_time: updated_time,
        members: members.map{|m| m.base_info  rescue {} },
      }
  end
  
end
 