
require 'rest-client'
require 'fileutils'
require 'addressable/uri'
require 'uri'

class ContractUploader < BaseUploader
    # mount_uploader :file, FileUploader

  
    # 使用 UUID 创建目录
    def store_dir
      "uploads/contract/#{model.uuid}"
    end

end
