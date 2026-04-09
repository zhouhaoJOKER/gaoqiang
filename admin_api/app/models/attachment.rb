class Attachment < ApplicationRecord
  mount_uploader :file, FileUploader
  # belongs_to :record
  has_one_attached :ac_file
  has_many_attached :files

  # 在初始化时生成 UUID（而不是在保存时）
  after_initialize :generate_uuid#, if: :new_record?
  # after_save :check_is_need_covert_pdf

  before_destroy :delete_file
  
  # 验证 UUID 存在
  validates :uuid, presence: true


  def file_encrypt_url
    Rails.application.credentials.upload_encrypt_url + file.url rescue ''
  end

  def name_url_info
    {
      name: name, 
      url:  "#{Rails.application.credentials.app_url}#{file.url}"   
    }
  end

  def base_info
    {
      uuid: uuid,
      name: name,
      content_type: content_type,
      byte_size: byte_size,
      user_id: user_id,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
  

  # 获取预览文件链接
  def get_view_url(tag=0)
    file_url = file.url rescue ''

    can_perview = 1
    if file_url.ends_with?(".doc")
      file_url = file_url.sub(".doc",".pdf")
    elsif  file_url.ends_with?(".docx")
      file_url = file_url.sub(".docx",".pdf")
    elsif  file_url.ends_with?(".xls")
      file_url = file_url.sub(".xls",".pdf")
    elsif  file_url.ends_with?(".xlsx")
      file_url = file_url.sub(".xlsx",".pdf")
    elsif  file_url.ends_with?(".ppt")
      file_url = file_url.sub(".ppt",".pdf")
    elsif  file_url.ends_with?(".pptx")
      file_url = file_url.sub(".pptx",".pdf")
    else
      can_perview = 0
    end


    can_perview = 1 if file_url.ends_with?(".pdf") 

    if file_url.ends_with?(".png") || file_url.ends_with?(".jpg") || file_url.ends_with?(".bmp") || file_url.ends_with?(".mp4")
      can_perview = 2
    end
    
    if can_perview == 1
      file_url = file_url 
    elsif can_perview == 2
      file_url = file_url 
    else
      file_url = "#{Rails.application.credentials.app_url}/uploads/canot_perview.png"   
    end
    file_url = "#{Rails.application.credentials.app_url}/pdf?uuid=#{uuid}"    if tag == 1
    file_url
  end

  # Attachment.gen_attachment
  def self.gen_attachment(file, kind='')
    attachment =   Attachment.create(
        file: File.open(file),
        kind: kind,
        content_type: Marcel::MimeType.for(Pathname.new(file)),
        name: File.basename(file),
    )
    # res = attachment.save
    p attachment.id
    attachment.id
  end

  # Attachment.upload_file(file)
  def self.upload_file(file)
    # file:11155
    id = Attachment.gen_attachment(file)
    "file:#{id}"
  end
  
  
  def check_is_need_covert_pdf
    file_path = file.path
    if System.is_word?(file_path)
      Rails.logger.info "需要转换pdf: #{file_path}"
      # System.convert_doc_to_pdf file_path
      ConvertPdfJob.perform_later(file_path)
    end
  end
  

  
  def force_check_covert_pdf
    file_path = file.path
    if System.is_word?(file_path)
      Rails.logger.info "需要转换pdf: #{file_path}"
      # 设置输出路径
      output_dir ||= File.dirname(file_path)
      output_name = File.basename(file_path, '.*') + '.pdf'

      output_file = File.join(output_dir, output_name)
      if File.exist?(output_file)
        Rails.logger.info "✅ 跳过转换，已存在pdf: #{output_name}"
      else
        System.convert_doc_to_pdf(file_path) rescue ''
      end
    end
  end
  
  # 判断文件pdf存在，不存在的话就转pdf
  def check_is_mmmm_pdf
    file_path = file.path
    dirname = File.dirname(file_path)
    base = File.basename(file_path, ".*")
    file_path_pdf = base + ".pdf"
    p file_path_pdf
    new_path = File.join(dirname, file_path_pdf + ".pdf")
    if File.exist? new_path
      p "pdf 已存在"
    else
      check_is_need_covert_pdf
    end
    

    # if check_is_need_covert_pdf
    #   check_is_need_covert_pdf
    # end
    
    
  end
  
  
  private
  
  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end



  def delete_file
    file_dir ||= File.dirname(file.path)
    FileUtils.remove_entry(file_dir)  if file_dir && File.exist?(file_dir)
    # File.delete(file.path) if file.path && File.exist?(file.path)
  end
end
# /data/企业标准体系/附件/解压文件/JYZDS-423/NB.JH423变频漆包线检验指导书.pdf