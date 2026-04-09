# app/services/file_sender.rb
require 'http'

class FileSender
  TIMEOUT = 30 # 30秒超时

  # 发送文件并附带额外参数
  def self.send_file_with_params(blob, target_url, params = {})
    # 创建临时文件
    Tempfile.open(blob.filename.to_s) do |file|
      file.binmode
      
      # 下载文件到临时文件
      blob.download do |chunk|
        file.write(chunk)
      end
      file.rewind
      
      # 构建多部分表单数据
      form_data = build_form_data(file, blob, params)
      
      # 发送请求
      response = HTTP.timeout(connect: TIMEOUT, read: TIMEOUT)
                    .post(target_url, form: form_data)
      
      handle_response(response)
    end
  end

  # 通过 blob key 发送文件（带参数）
  def self.send_by_key_with_params(blob_key, target_url, params = {})
    blob = ActiveStorage::Blob.find_by(key: blob_key)
    return { error: "Blob not found" } unless blob
    
    send_file_with_params(blob, target_url, params)
  end



   # 流式上传（适合大文件）
   # 流式上传大文件（修复版）
def self.stream_upload(blob, target_url, params = {})
  # 使用 blob.open 块确保文件正确关闭
  blob.open do |file|
    # 创建多部分表单
    form = HTTP::FormData::Multipart.new do |f|
      # 添加文件部分
      f.file(:file, file, filename: blob.filename.to_s, content_type: blob.content_type)

      # 添加额外参数
      params.each do |key, value|
        f.field(key, value.to_s)
      end
    end

    # 发送请求
    response = HTTP.timeout(connect: TIMEOUT, read: TIMEOUT)
                  .post(target_url, body: form.body, headers: form.headers)

    handle_response(response)
  end
end


#   FileSender.stream_upload(
#   large_blob,
#   'https://api.example.com/upload',
#   {
#     file_size: large_blob.byte_size,
#     checksum: large_blob.checksum
#   }
# )

  # 直接上传文件（不通过 Active Storage）
  def self.direct_upload(file, target_url, params = {})
    Tempfile.open(file.original_filename) do |tempfile|
      FileUtils.copy_stream(file, tempfile)
      tempfile.rewind
      
      form_data = {
        file: HTTP::FormData::File.new(
          tempfile,
          filename: file.original_filename,
          content_type: file.content_type
        )
      }
      
      # 添加额外参数
      params.each do |key, value|
        form_data[key] = value.to_s
      end
      
      response = HTTP.timeout(connect: TIMEOUT, read: TIMEOUT)
                    .post(target_url, form: form_data)
      
      handle_response(response)
    end
  end
    #   
    #   result = FileSender.direct_upload(
    #     params[:file],
    #     'https://api.example.com/upload',
    #     {
    #       user_id: current_user.id,
    #       description: params[:description]
    #     }
    #   )
    

  private

  # 构建多部分表单数据
  def self.build_form_data(file, blob, params)
    form_data = {
      file: HTTP::FormData::File.new(
        file,
        filename: blob.filename.to_s,
        content_type: blob.content_type
      )
    }
    
    # 添加额外参数
    params.each do |key, value|
      form_data[key] = value.to_s
    end
    
    form_data
    p form_data
  end

  # 处理响应（保持不变）
  def self.handle_response(response)
    if response.status.success?
      { success: true, body: response.body.to_s }
    else
      { 
        error: "API responded with #{response.status}",
        status: response.status,
        body: response.body.to_s 
      }
    end
  rescue HTTP::TimeoutError => e
    { error: "Request timed out: #{e.message}" }
  rescue => e
    { error: "HTTP request failed: #{e.message}" }
  end
end