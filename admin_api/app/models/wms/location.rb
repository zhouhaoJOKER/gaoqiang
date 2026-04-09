class Wms::Location < ApplicationRecord

    # columns: warehouse_id, area_id, name, abbr, code, type_id, is_active, is_adjustment, is_reservation, sort, description, user_id, updater_id, py, pinyin, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    validates :name, length: { in: 2..20 },  presence: true

    before_save :gen_py

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :warehouse, class_name: "Wms::Warehouse", foreign_key: "warehouse_id", optional: true
    belongs_to :area, class_name: "Wms::Area", foreign_key: "area_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            warehouse_id: warehouse_id,
            warehouse_name: (warehouse.name rescue ""),
            area_id: area_id,
            area_name: (area.name rescue ""),
            name: name,
            abbr: abbr,
            code: code,
            type_id: type_id,
            is_active: is_active,
            is_adjustment: is_adjustment,
            is_reservation: is_reservation,
            sort: sort,
            description: description,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            py: py,
            pinyin: pinyin,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        code: code,
        name: name,
        }
    end
    

    def self.imp_exp_hander
        %w(warehouse_id  area_id  name  abbr  code  type_id  is_active  is_adjustment  is_reservation  sort  description  user_id  updater_id  py  pinyin  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
