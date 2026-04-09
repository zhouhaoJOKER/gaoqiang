# frozen_string_literal: true

class Api::V1::ScaffoldControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  namespace "api:v1:scaffold_controller"

  # 当名称为 Crm::Client 等形式时，提取模块路径（小写目录名）
  def module_path
    return nil unless class_name.include?("::")
    class_name.split("::")[0..-2].join("::").underscore
  end

  # 模型单数名（最后一段，用于实例变量、params 等）
  def singular_name
    if class_name.include?("::")
      class_name.split("::").last.underscore
    else
      super
    end
  end

  # 模型复数名
  def plural_name
    singular_name.pluralize
  end

  # 控制器文件路径：有模块时放到 api/v1/<module>/ 下
  def controller_file_path
    if module_path.present?
      "app/controllers/api/v1/#{module_path}/#{plural_name}_controller.rb"
    else
      "app/controllers/api/v1/#{plural_name}_controller.rb"
    end
  end

  def generate_controller
    # 有模块时确保目录存在
    if module_path.present?
      empty_directory File.join("app/controllers/api/v1", module_path)
    end
    template "controller.rb.erb", controller_file_path
  end

  def create_controller_files
    generate_controller
  end

  hook_for :template_engine, as: :scaffold do |_template_engine| end
  hook_for :resource_route, in: :rails, required: false do |_resource_route| end
  hook_for :resource_controller, in: :rails, required: false do |_resource_controller| end
  hook_for :assets, in: :rails, required: false do |_assets| end
  hook_for :helper, in: :rails, required: false do |_helper| end
  hook_for :test_framework, in: :rails, required: false do |_test_framework| end

  # 控制器类名：有模块时为 Crm::ClientsController，无模块时为 Api::V1::ClientsController
  def controller_class_name
    if module_path.present?
      "#{module_path.camelize}::#{plural_name.camelize}Controller"
    else
      "Api::V1::#{plural_name.camelize}Controller"
    end
  end

  # 模板中使用的控制器类名（class 定义那一行）
  def controller_class_name_for_template
    if module_path.present?
      "#{module_path.camelize}::#{plural_name.camelize}Controller"
    else
      "#{plural_name.camelize}Controller"
    end
  end

  def permitted_params
    default_params = %w[code name parent_id status sort remark]
    params_list = if options[:attributes]
      options[:attributes].split(",")
    else
      default_params
    end
    params_list.map { |attr| ":#{attr}" }.join(", ")
  end

  class_option :attributes, type: :string, desc: "Comma-separated list of attributes (e.g. code,name,parent_id)"

  # 模型类名（与 class_name 一致）
  def model_class_name
    class_name
  end

  # 带顶层引用的模型类名，避免在 Api::V1::Module 下解析成 Api::V1::Module::Model
  def model_class_name_with_root
    "::#{class_name}"
  end

  def human_name
    class_name.underscore.humanize
  end

  def orm_class
    model_class_name.to_s
  end
end
