class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  # 安全防护
  # attr_readonly :creater_id  # 禁止修改创建人



  # before_create :auto_set_creater
  before_create :generate_code, :if => :skip_generate_code?
  # before_save :auto_set_updater


  # 真正的虚拟字段方法
  def created_time
    created_at&.strftime('%Y-%m-%d %H:%M') rescue ''
  end

  def updated_time
    updated_at&.strftime('%Y-%m-%d %H:%M') rescue ''
  end

  # 生成拼音字段（仅当存在 name 属性且 ActiveRecord 提供 name_changed?；无 name 列的模型请自行重写 gen_py）
  def gen_py
    return unless respond_to?(:name_changed?, true) && name_changed?

    self.py = Pinyin.t(self.name) { |letters| letters[0] } if self.class.column_names.include?("py")
    self.pinyin = Pinyin.t(self.name) if self.class.column_names.include?("pinyin")
  end


  # 定义可公开访问的关联字段
  attr_accessor :current_user

  # 定义通用的可搜索属性逻辑
  def self.ransackable_attributes(auth_object = nil)
    # 获取所有数据库列名并转为符号
    column_names = self.column_names.map(&:to_sym)
    
    # 默认排除的字段（符号形式）
    excluded_columns = [
      :encrypted_password,   # 常见敏感字段示例
      :reset_password_token, # 可根据需要调整默认黑名单
      :lock_version          # 乐观锁字段
    ] 
    
    # 合并子类自定义排除字段
    excluded_columns += ransack_excluded_attributes
    
    # 返回过滤后的白名单属性
    column_names.map(&:to_s) - excluded_columns.map(&:to_s)
  end

  # 允许所有关联可搜索
  def self.ransackable_associations(auth_object = nil)
    # 获取所有关联的名称并转换为字符串数组
    reflect_on_all_associations.map { |a| a.name.to_s } + _ransackers.keys
  end
  
  # 允许子类通过覆盖此方法添加自定义排除字段
  def self.ransack_excluded_attributes
    []
  end


  def skip_generate_code?
  # 返回 true 或false来决定是否跳过回调
      true # 或者 false 根据条件判断
  end


  # 字段信息
  def columns_info
    self.class.columns.map{|e|[e.name,e.type.to_s]}
  end

  # 字段列表
  def column_names
    self.class.columns.map{|e|e.name}
  end
  
  def i18n_column_names
    # t("update")
    column_names.map{|e| I18n.t "#{self.model_name.singular}.#{e}"}
  end

  def self.il8n_imp_exp_hander
    self.imp_exp_hander.map{|e| I18n.t "#{self.model_name.singular}.#{e}"}
  end
  

  # 关联关系
  def reflect_info
    self.class.reflect_on_all_associations
  end

  def my_url(model)
    eval("Rails.application.routes.url_helpers.#{model.model_name.singular}_url(self, :only_path => true)")#, :host =>Setting.host_name)
  end

  # 创建前生成编号：已有 code 不覆盖；无 code 时调用单号服务按表名生成
  def generate_code
    return unless self.class.column_names.include?("code")
    return if self[:code].present?
    self.code = DocNumberService.next_number(self.class.table_name)
  end


  #  根据 id 获取 name 值并缓存,减少 where 查询
  def self.get_name(id, force=true, name=-1)
    # p '>>>>'
    # p self.model_name
      cache_key = "#{self.model_name.plural}_name#{id}"
      data = Rails.cache.read(cache_key)
      unless data.present? && force
          data=(name == -1)? (self.find(id).name rescue '-1'):name
          Rails.cache.write(cache_key, data)
      end
      return data
  end


  def bst(time)
    time.in_time_zone("#{Setting.time_zone}").strftime("%Y-%m-%d %H:%M:%S") rescue time
  end

  def bt(time)
    time.in_time_zone("#{Setting.time_zone}").strftime("%Y-%m-%d") rescue  time
  end

  
  private

  def auto_set_creater
    if self.class.column_names.include?("creater_id")
      return if  creater_id.present?  # 防止覆盖已有值
      raise 'Current user not set' unless current_user
      self.creater_id ||= current_user.id
    end

    if self.class.column_names.include?("updater_id")
      self.updater_id ||= current_user.id  # 创建时 updater=creater
    end

    if self.class.column_names.include?("uuid")
      self.uuid ||= System.uuid
    end


  end

  # def auto_set_updater
  #   if self.class.column_names.include?("updater_id")
  #     return unless  will_save_change_to_attribute?(:updater_id)  # 防止递归更新
  #     raise 'Current user not set' unless current_user
  #     self.updater_id = current_user.id
  #   end
  # end
end
