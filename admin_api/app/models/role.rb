class Role < ApplicationRecord
  validates :name, length: { in: 2..20 },  presence: true, uniqueness:true

  attribute :created_time, :string
  attribute :updated_time, :string

  serialize :menu_ids

  belongs_to :company, class_name: "Company", optional: true
 

  def format_arr_company_ids
    company_ids.split(",").reject(&:empty?) rescue []
  end
  

  def base_info
      {
          id: id,
          code: code,
          sign: sign,
          name: name,
          is_open: is_open,
          company_id: company_id,
          category: category,
          sort: sort,
          describe: describe,
          company_ids: format_arr_company_ids,
          user_id: user_id,
          created_time: created_time,
          updated_time: updated_time,
          menu_ids: menu_ids

      }
  end
end
