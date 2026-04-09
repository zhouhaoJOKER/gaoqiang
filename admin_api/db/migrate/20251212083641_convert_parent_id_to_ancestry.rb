class ConvertParentIdToAncestry < ActiveRecord::Migration[8.0]
  def up
    # 重置所有记录的 ancestry
    Department.update_all(ancestry: nil)
    
    # 递归构建 ancestry 路径
    build_ancestry_paths
  end

  def down
    # 回滚时清空 ancestry
    Department.update_all(ancestry: nil)
  end

  private

  def build_ancestry_paths
    # 找到所有根节点 (parent_id 为 nil)
    roots = Department.where(parent_id: nil)
    
    # 处理每个根节点及其后代
    roots.each do |root|
      process_node(root)
    end
  end

  def process_node(node)
    # 获取节点的所有直接子节点
    children = Department.where(parent_id: node.id)
    
    children.each do |child|
      # 设置子节点的 ancestry 路径
      child_ancestry = if node.ancestry.present?
                         "#{node.ancestry}/#{node.id}"
                       else
                         node.id.to_s
                       end
      
      # 直接更新数据库（跳过回调和验证）
      child.update_columns(ancestry: child_ancestry)
      
      # 递归处理子节点
      process_node(child)
    end
  end
end
