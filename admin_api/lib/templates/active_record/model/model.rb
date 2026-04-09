<% module_namespacing do -%>
class <%= class_name %> < ApplicationRecord

    # columns: <%= attributes.map(&:name).join(",") %>,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

<% if attributes.map(&:name).include?("name") -%>
    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true
<% end -%>
<% if attributes.map(&:name).include?("name") && attributes.map(&:name).include?("parent_id") -%>

    validates_uniqueness_of :name, :scope => :parent_id
<% end -%>
<% if attributes.map(&:name).include?("code") && !attributes.map(&:name).include?("name") -%>
    validates :code, length: { in: 2..20 },  presence: true
<% end -%>

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
<% if attributes.map(&:name).include?("name") && (attributes.map(&:name).include?("py") || attributes.map(&:name).include?("pinyin")) -%>
    before_save :gen_py
<% end -%>

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

<% attributes.select { |a| a.name.end_with?("_id") && a.name != "parent_id" }.each do |attribute| -%>
<% model_name = attribute.name.gsub("_id", "") -%>
<% if model_name == "user" -%>
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
<% elsif model_name == "updater" -%>
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
<% elsif model_name == "manager" -%>
    belongs_to :manager, class_name: "User", foreign_key: "manager_id", optional: true
<% elsif model_name == "company" -%>
    belongs_to :company, class_name: "Company", optional: true
<% elsif model_name == "status" -%>
    belongs_to :status, class_name: "Property", optional: true, foreign_key: "status_id", optional: true
<% elsif model_name == "source" -%>
    belongs_to :source, class_name: "Property", foreign_key: "source_id", optional: true
<% else -%>
    belongs_to :<%= model_name %>, class_name: "<%= model_name.camelize %>", foreign_key: "<%= attribute.name %>", optional: true
<% end -%>
<% end -%>
<% if attributes.map(&:name).include?("parent_id") -%>
    belongs_to :parent, class_name: "<%= class_name %>", optional: true
<% end -%>
<% if attributes.map(&:name).include?("parent_id") -%>
    has_many :children, class_name: "<%= class_name %>", foreign_key: "parent_id"
<% end -%>
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
<% attributes.each do |attribute| -%>
<% if attribute.name.end_with?("_id") && attribute.name != "parent_id" -%>
<% model_name = attribute.name.gsub("_id", "") -%>
            <%= attribute.name %>: <%= attribute.name %>,
<% if model_name == "user" -%>
            user_name: (user.name rescue ""),
<% elsif model_name == "updater" -%>
            updater_name: (updater.name rescue ""),
<% elsif model_name == "manager" -%>
            manager_name: (manager.name rescue ""),
<% elsif model_name == "company" -%>
            company_name: (company.name rescue ""),
<% elsif model_name == "status" -%>
            status_name: (status.name rescue ""),
<% elsif model_name == "source" -%>
            source_name: (source.name rescue ""),
<% else -%>
            <%= model_name %>_name: (<%= model_name %>.name rescue ""),
<% end -%>
<% else -%>
            <%= attribute.name %>: <%= attribute.name %>,
<% end -%>
<% end -%>
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
<% if attributes.map(&:name).include?("code") -%>
        code: code,
<% end -%>
<% if attributes.map(&:name).include?("name") -%>
        name: name,
<% end -%>
<% if attributes.map(&:name).include?("parent_id") -%>
        parent_id: parent_id,
<% end -%>
        }
    end
    

    #导入导出头部设置
    # <%= class_name %>.imp_exp_hander
    def self.imp_exp_hander
        %w(<%= attributes.map(&:name).join("  ") %>  created_at  updated_at)
    end

    # 示例计算金额
    # <%= class_name %>.last.sum_amount("receive_amount", 1000)
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
<% end -%>
# #<%= class_name.underscore.humanize %> <%= file_name.pluralize %>
# match "<%= file_name.pluralize %>"  => "<%= file_name.pluralize %>#index", via: :get
# match "<%= file_name.pluralize %>"  => "<%= file_name.pluralize %>#create", via: :post
# match "<%= file_name.pluralize %>/:id"  => "<%= file_name.pluralize %>#update", via: :put
# match "<%= file_name.pluralize %>/:id"  => "<%= file_name.pluralize %>#show", via: :get
# match "<%= file_name.pluralize %>/:id"  => "<%= file_name.pluralize %>#destroy", via: :delete
# match "<%= file_name.pluralize %>/batch_action"  => "<%= file_name.pluralize %>#batch_action", via: :post
# match "<%= file_name.pluralize %>/import"  => "<%= file_name.pluralize %>#import", via: :post
