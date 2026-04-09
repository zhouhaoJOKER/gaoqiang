class Company < ApplicationRecord
    # logo,parent_id,abbr,name,credit_code,legal_name,status_id,reg_date,reg_capital,reg_address,company_type_id,contact,email,business_scope,industry_id,business_reg_number,business_term,approval_date,region_id,organization_code,user_id

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true


    validates_uniqueness_of :name, :scope => :parent_id

    # before_create :genereate_parent_code
    before_save :gen_py

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :parent, class_name: "Department", optional: true
    

    has_many :children, class_name: "Department", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string


  def base_info
      {
        id: id,
        name: name,
        abbr: abbr,
        status_id: status_id,
        credit_code: credit_code,
        legal_name: legal_name,
        parent_id: parent_id,
        user_id: user_id,
        user_name: (user.name rescue ""),
        created_time: created_time,
        updated_time: updated_time,
      }
  end
  
  
end
