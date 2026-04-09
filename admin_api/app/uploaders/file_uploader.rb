class FileUploader < BaseUploader
    # mount_uploader :file, FileUploader

  
    # 使用 UUID 创建目录
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{System.year}//#{model.id}"
    end

    # # 处理模型未持久化的情况
    # def identifier
    #   model.uuid || super
    # end
  
end
