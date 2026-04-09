class Property < ApplicationRecord
    # sign parent_id name py sort color is_open user_id
    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    # validates :name, length: { in: 2..20 },  presence: true

    # 同名可在不同父级下重复（如多个大类下都有「100ml」规格）
    validates :name, uniqueness: { scope: [:sign, :parent_id] }

    belongs_to :parent, class_name: "Property", foreign_key: "parent_id", optional: true
    has_many :children, class_name: "Property", foreign_key: "parent_id"

    before_save :gen_py
    # before_update :gen_py
    # 
    #de
    def base_info
        {
            id: id,
            parent_id: parent_id,
            sign: sign,
            name: name,
            py: py,
            color: color,
            abbr: abbr,
        }
    end
end
