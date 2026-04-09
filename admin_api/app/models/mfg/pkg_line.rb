class Mfg::PkgLine < ApplicationRecord

    # columns: contract_id,pkg_handover_id,line_id,record_date,weather,temperature,product_id,name,code,customer_trademark_name,...,user_id,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :pkg_handover, class_name: "Mfg::PkgHandover", foreign_key: "pkg_handover_id", optional: true
    belongs_to :line, class_name: "Line", foreign_key: "line_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :line_foreman, class_name: "LineForeman", foreign_key: "line_foreman_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            pkg_handover_id: pkg_handover_id,
            pkg_handover_name: (pkg_handover.name rescue ""),
            line_id: line_id,
            line_name: (line.name rescue ""),
            record_date: record_date,
            weather: weather,
            temperature: temperature,
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            customer_trademark_name: customer_trademark_name,
            planned_total_qty_kl: planned_total_qty_kl,
            planned_total_pieces: planned_total_pieces,
            packaging_batch_number: packaging_batch_number,
            semi_finished_batch_number: semi_finished_batch_number,
            specific_gravity: specific_gravity,
            packaging_spec: packaging_spec,
            net_weight_per_bottle: net_weight_per_bottle,
            empty_bottle_weight: empty_bottle_weight,
            filling_range: filling_range,
            standard_weight_per_bottle: standard_weight_per_bottle,
            standard_weight_per_box: standard_weight_per_box,
            packaging_key_points: packaging_key_points,
            formal_filling_start_time: formal_filling_start_time,
            formal_filling_end_time: formal_filling_end_time,
            packages_this_shift: packages_this_shift,
            filling_debug_air_pressure: filling_debug_air_pressure,
            filling_debug_temperature: filling_debug_temperature,
            filling_debug_horizontal_temp: filling_debug_horizontal_temp,
            filling_debug_vertical_temp: filling_debug_vertical_temp,
            filling_debug_notes: filling_debug_notes,
            labeling_machine_result: labeling_machine_result,
            filling_machine_result: filling_machine_result,
            capping_machine_result: capping_machine_result,
            sealing_machine_result: sealing_machine_result,
            coding_machine_result: coding_machine_result,
            shrink_film_machine_result: shrink_film_machine_result,
            packing_machine_result: packing_machine_result,
            operator_info: operator_info,
            line_foreman_id: line_foreman_id,
            line_foreman_name: (line_foreman.name rescue ""),
            other: other,
            remark: remark,
            user_id: user_id,
            user_name: (user.name rescue ""),
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
    

    #导入导出头部设置
    # Mfg::PkgLine.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  pkg_handover_id  line_id  record_date  weather  temperature  product_id  name  code  customer_trademark_name  planned_total_qty_kl  planned_total_pieces  packaging_batch_number  semi_finished_batch_number  specific_gravity  packaging_spec  net_weight_per_bottle  empty_bottle_weight  filling_range  standard_weight_per_bottle  standard_weight_per_box  packaging_key_points  formal_filling_start_time  formal_filling_end_time  packages_this_shift  filling_debug_air_pressure  filling_debug_temperature  filling_debug_horizontal_temp  filling_debug_vertical_temp  filling_debug_notes  labeling_machine_result  filling_machine_result  capping_machine_result  sealing_machine_result  coding_machine_result  shrink_film_machine_result  packing_machine_result  operator_info  line_foreman_id  other  remark  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::PkgLine.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end


    # 生成默认的状态 这个不用生成
    # def generate_default_stages
    #     stages = [
    #         { project_id: id, sort: "1", name: "计划任务" },
    #         { project_id: id, sort: "2", name: "进行中" },
    #         { project_id: id, sort: "3", name: "开发完成待测试" },
    #         { project_id: id, sort: "4", name: "已完成" }
    #     ]
    #     stages.each do |single|
    #         Pm::Stage.create(single)
    #     end
    # end
end
# #Mfg/pkg line pkg_lines
# match "pkg_lines"  => "pkg_lines#index", via: :get
# match "pkg_lines"  => "pkg_lines#create", via: :post
# match "pkg_lines/:id"  => "pkg_lines#update", via: :put
# match "pkg_lines/:id"  => "pkg_lines#show", via: :get
# match "pkg_lines/:id"  => "pkg_lines#destroy", via: :delete
# match "pkg_lines/batch_action"  => "pkg_lines#batch_action", via: :post
# match "pkg_lines/import"  => "pkg_lines#import", via: :post
