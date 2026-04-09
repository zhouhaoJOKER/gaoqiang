# app/services/http_file_uploader.rb
require 'rest-client'

class FileSender
  # FileSender.down_and_upload(blob,uuid)
  def self.down_and_upload(blob,uuid, api_url=Setting.ai_contract_audit_url)
    object_key = blob.filename.to_s
    tempfile = Tempfile.new([File.basename(object_key), File.extname(object_key)])
    
    destination_path = tempfile.path
    p destination_path

    tmp_file = File.binwrite(destination_path, blob.download)
    # destination_path

    result = RestClient.post api_url, 
     {:file => File.new(destination_path), :task_id => uuid, :multipart => true}, read_timeout: 10
    p result.to_json

    # path = "/opt/fmanager/admin_api/tmp/框架采购合同-水泵-新界.docx"
    # task_id = "873e7d9d-cfd2-4683-8509-a16a0f762a5f"
    # SyncAuditContract.perform_now(path, task_id, api_url=Setting.ai_contract_audit_url)


    # path = "/opt/fmanager/admin_api/tmp/开票平台软件销售合同2018-新界.docx"
    # task_id = "3c95087e-75d6-49e1-a56d-0eb9fcf79598"
    # SyncAuditContract.perform_now(path, task_id, api_url=Setting.ai_contract_audit_url)

    # path = "/opt/fmanager/admin_api/tmp/商业水泵合同23232323232.docx"
    # task_id = "8fc9ead3-b16b-4e4e-bf94-9fdda66cddc3"
    # SyncAuditContract.perform_now(path, task_id, api_url=Setting.ai_contract_audit_url)


    
    
  end


  # def self.upload(attachment, api_url, params = {}, headers = {})
  #   # 验证附件存在
  #   # raise ArgumentError, "附件未找到" unless attachment.attached?
    
  #   # 创建临时文件
  #   Tempfile.create do |tempfile|
  #     tempfile.binmode
      
  #     # 流式下载文件到临时文件
  #     attachment.download { |chunk| tempfile.write(chunk) }
  #     tempfile.rewind
      
  #     # 构建表单数据
  #     form = build_form_data(attachment, tempfile, params)
      
  #     # 发送请求
  #     send_request(api_url, form, headers)
  #   end
  # end

  # private

  # def self.build_form_data(attachment, file, params)
  #   # 基础表单数据
  #   form = {
  #     file: HTTP::FormData::File.new(
  #       file.path,
  #       filename: attachment.filename.to_s,
  #       content_type: attachment.content_type
  #     )
  #   }
    
  #   # 添加额外参数
  #   params.each do |key, value|
  #     form[key] = HTTP::FormData::Part.new(value.to_s)
  #   end
    
  #   form
  # end

  # def self.send_request(url, form, headers)
  #   response = HTTP.headers(default_headers.merge(headers))
  #       .post(url, form: form)
  #   handle_response(response)

  # rescue HTTP::Error => e
  #   Rails.logger.error "HTTP 错误: #{e.message}"
  #   raise
  # end

  # def self.default_headers
  #   {
  #     'Accept' => 'application/json',
  #     'User-Agent' => "RailsApp/#{Rails.version}"
  #   }
  # end


  # # 处理响应（保持不变）
  # def self.handle_response(response)
  #   if response.status.success?
  #     { success: true, body: response.body.to_s }
  #   else
  #     { 
  #       error: "API responded with #{response.status}",
  #       status: response.status,
  #       body: response.body.to_s 
  #     }
  #   end
  # rescue HTTP::TimeoutError => e
  #   { error: "Request timed out: #{e.message}" }
  # rescue => e
  #   { error: "HTTP request failed: #{e.message}" }
  # end
end