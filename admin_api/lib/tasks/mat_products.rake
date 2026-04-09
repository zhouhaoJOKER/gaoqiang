require "csv"

module MatProductsCsvImport
  module_function

  SIGN = "product_category".freeze

  def normalize_spec_label(nominal)
    s = nominal.to_s.strip
    return "未标注" if s.blank?
    m = s.match(/(\d+(?:\.\d+)?)\s*(ml|l)/i)
    return s if m.nil?
    amount = m[1].to_f
    return s if amount.nan?
    unit = m[2].downcase
    if unit == "l"
      (amount == amount.to_i) ? "#{amount.to_i}L" : "#{amount}L"
    elsif amount == amount.to_i
      "#{amount.to_i}ml"
    else
      "#{amount}ml"
    end
  end

  def ensure_parent_category!(name)
    return nil if name.blank?
    Property.find_or_create_by!(sign: SIGN, parent_id: nil, name: name.strip)
  end

  def ensure_spec_category!(parent, spec_name)
    return nil if parent.blank? || spec_name.blank?
    Property.find_or_create_by!(sign: SIGN, parent_id: parent.id, name: spec_name.to_s.strip)
  end
end

namespace :import do
  desc "导入产品CSV到 Mat::Product（默认读取 ../../product/products.csv）；二级分类：大类 parent_id=nil，规格为子级，product.category_id 指向规格"
  task mat_products_csv: :environment do
    file_path = ENV["CSV_PATH"].presence || Rails.root.join("..", "..", "product", "products.csv").to_s
    unless File.exist?(file_path)
      puts "错误: CSV 文件不存在 -> #{file_path}"
      exit 1
    end

    rows = CSV.read(file_path, headers: true, encoding: "bom|utf-8")
    puts "开始导入，文件: #{file_path}，总行数: #{rows.size}"

    success_count = 0
    failed_count = 0
    skip_count = 0

    rows.each_with_index do |row, idx|
      category_name = row["category_name"].to_s.strip
      name = row["name"].to_s.strip
      code = row["product_code"].to_s.strip

      if name.blank?
        skip_count += 1
        puts "第 #{idx + 2} 行跳过：name 为空"
        next
      end

      begin
        parent = MatProductsCsvImport.ensure_parent_category!(category_name)
        spec_label = MatProductsCsvImport.normalize_spec_label(row["nominal_capacity"])
        spec_prop = parent ? MatProductsCsvImport.ensure_spec_category!(parent, spec_label) : nil

        product = if code.present?
          Mat::Product.find_or_initialize_by(code: code)
        else
          Mat::Product.find_or_initialize_by(name: name, category_id: spec_prop&.id)
        end

        product.assign_attributes(
          name: name,
          code: code.presence || product.code,
          category_id: spec_prop&.id || product.category_id,
          image_url: row["image_url"].to_s.strip,
          logo: row["image_url"].to_s.strip.presence || product.logo,
          material: row["material"].to_s.strip,
          full_capacity: row["full_capacity"].to_s.strip,
          nominal_capacity: row["nominal_capacity"].to_s.strip,
          caliber: row["caliber"].to_s.strip,
          cap_height: row["cap_height"].to_s.strip,
          max_diameter: row["max_diameter"].to_s.strip,
          label_size: row["label_size"].to_s.strip,
          description: row["detail_url"].to_s.strip.presence || product.description
        )

        if product.save
          success_count += 1
        else
          failed_count += 1
          puts "第 #{idx + 2} 行失败: #{product.errors.full_messages.join(', ')}"
        end
      rescue => e
        failed_count += 1
        puts "第 #{idx + 2} 行异常: #{e.message}"
      end
    end

    puts "导入完成: 成功 #{success_count}，失败 #{failed_count}，跳过 #{skip_count}"
  end

  desc "将已有产品的扁平 product_category（无父级）迁移为二级：在大类下按 nominal_capacity 生成规格子类并更新 category_id"
  task mat_products_migrate_two_level_categories: :environment do
    migrated = 0
    skipped = 0
    errors = 0

    Mat::Product.find_each do |product|
      prop = product.category
      unless prop && prop.sign == MatProductsCsvImport::SIGN
        skipped += 1
        next
      end
      # 已是子级
      if prop.parent_id.present?
        skipped += 1
        next
      end

      parent = prop
      spec_label = MatProductsCsvImport.normalize_spec_label(product.nominal_capacity)
      begin
        child = MatProductsCsvImport.ensure_spec_category!(parent, spec_label)
        product.update_columns(category_id: child.id) if child
        migrated += 1
      rescue => e
        errors += 1
        puts "产品 ##{product.id} 迁移失败: #{e.message}"
      end
    end

    puts "迁移完成: 已更新 #{migrated} 条，跳过 #{skipped} 条，失败 #{errors} 条"
  end
end
