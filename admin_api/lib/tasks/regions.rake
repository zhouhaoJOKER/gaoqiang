# frozen_string_literal: true

require "set"

REGIONS_JSON_URL = "https://raw.githubusercontent.com/kamaslau/chinese_regions/master/out/all.min.json"
REGIONS_JSON_PATH = "tmp/all.min.json"

namespace :regions do
  desc "Import provinces, cities, counties from chinese_regions (download to tmp then import)"
  task import: :environment do
    require "open-uri"

    path = Rails.root.join(REGIONS_JSON_PATH)

    # 1. 尝试下载到本地
    unless File.exist?(path)
      puts "Downloading #{REGIONS_JSON_URL} to #{path} ..."
      begin
        body = URI.open(REGIONS_JSON_URL, read_timeout: 60).read
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, body)
        puts "Downloaded successfully."
      rescue StandardError => e
        puts "Download failed: #{e.message}"
        puts ""
        puts "Please manually download the file and save to:"
        puts "  #{path}"
        puts "  URL: #{REGIONS_JSON_URL}"
        puts ""
        exit 1
      end
    else
      puts "Using local file: #{path}"
    end

    # 2. 从本地文件读取并导入
    data = JSON.parse(File.read(path))
    Province.transaction do
      # 1. 清空（可选，便于重复执行）
      County.delete_all
      City.delete_all
      Province.delete_all

      # 2. 导入省（源数据可能重复 code，只保留第一条；code 统一为整数避免 260001 vs "260001" 重复）
      province_by_code = {}
      data["province"].each do |p|
        code = p["code"].to_i
        next if code.zero?
        next if province_by_code.key?(code)
        province_by_code[code] = Province.create(code: code, name: p["name"], py: Pinyin.t(p["name"]) { |letters| letters[0] })
      end
      puts "Provinces: #{Province.count}"

      # 3. 导入市（p_code 对应省；同一 code 只保留第一条；code 统一为整数）
      city_by_code = {}
      data["city"].each do |c|
        code = c["code"].to_i
        next if code.zero?
        next if city_by_code.key?(code)
        p_code = c["p_code"].to_i
        province = province_by_code[p_code]
        unless province
          puts "WARN: province not found for p_code=#{p_code} city=#{c["name"]}"
          next
        end
        city_by_code[code] = City.create(province_id: province.id, code: code, name: c["name"], py: Pinyin.t(c["name"]) { |letters| letters[0] })
      end
      puts "Cities: #{City.count}"

      # 4. 导入县/区（c_code 对应市；同一 code 只保留第一条；code 统一为整数）
      county_codes_seen = Set.new
      data["county"].each do |c|
        code = c["code"].to_i
        next if code.zero?
        next if county_codes_seen.include?(code)
        county_codes_seen.add(code)
        c_code = c["c_code"].to_i
        city = city_by_code[c_code]
        unless city
          puts "WARN: city not found for c_code=#{c_code} county=#{c["name"]}"
          next
        end
        County.create(city_id: city.id, code: code, name: c["name"], py: Pinyin.t(c["name"]) { |letters| letters[0] })
      end
      puts "Counties: #{County.count}"
    end
    puts "Done."
  end
end
