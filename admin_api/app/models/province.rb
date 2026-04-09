# frozen_string_literal: true

class Province < ApplicationRecord
  has_many :cities, dependent: :destroy
  has_many :counties, through: :cities

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  # 省市区数据来自 JSON 导入，code 使用行政区划码，不执行 ApplicationRecord 的 generate_code
  def skip_generate_code?
    false
  end
end
