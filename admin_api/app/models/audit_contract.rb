class AuditContract < ApplicationRecord
    #  audit_contract parent_id:integer:index version:string uuid:string:index part_a:string part_b:string contract_number:string project_name:string department_id:integer user_id:integer is_realtime:boolean status:string file:string result:json result_at:string result_file:string remark:text

    validates :contract_number, length: { in: 2..20 },  presence: true, uniqueness:true

    belongs_to :department, class_name: "Department", optional: true
    belongs_to :user, class_name: "User", optional: true
    belongs_to :parent, class_name: "AuditContract", optional: true
    

    has_many :children, class_name: "AuditContract", foreign_key: "parent_id"

    has_one_attached :files

    
    def self.ransackable_associations(auth_object = nil)
      ["children", "parent"]
    end


    def base_info
        {
            id: id, 
            parent_id: parent_id ,
            version: version ,
            uuid: uuid ,
            part_a: part_a ,
            part_b: part_b ,
            contract_number: contract_number ,
            project_name: project_name ,
            department_id: department_id ,
            user_id: user_id ,
            is_realtime: is_realtime ,
            status: status ,
            file: (files.blob rescue '') ,
            file_url: (files.blob.url rescue ''),
            children: children.map{|e|e.child_info},

            result: result ,
            result_at: result_at ,
            result_file: result_file ,
            remark: remark ,
            created_at:  bst(created_at) ,
            updated_at:  bst(updated_at) ,
        }
        
    end

    def child_info
        {
            id: id, 
            parent_id: parent_id ,
            version: version ,
            uuid: uuid ,
            status: status ,
            file: (files.blob rescue '') ,
            file_url: (files.blob.url rescue ''),
            created_at: bst(created_at) ,
        }
        
    end
    
    
end
