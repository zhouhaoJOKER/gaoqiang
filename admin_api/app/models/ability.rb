# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      roles_for_anonymous
    elsif user.admin?
      can :manage, :all
    elsif user.role.present?
      if user.role.sign == "user" # 普通用户权限
        can :create, User
        can :read, User, id: user.id
        can :update, User, id: user.id
        can :delete, User, id: user.id
        can :import, User
        can :batch_action, User
        can :change_password, User, id: user.id
         
        
      elsif user.role.sign == "department" #部门数据权限
        can :create, User
        can :read, User, department_id: user.department.subtree_ids||user.department_id
        can :update, User, department_id: user.department.subtree_ids||user.department_id
        can :delete, User, id: user.department.subtree_ids||user.department_id
        can :import, User
        can :batch_action, User
        can :reset_password, User, department_id: user.department.subtree_ids||user.department_id
        
      elsif user.role.sign == "company" #公司数据权限
        can :create, User
        can :read, User, company_id: user.company_id
        can :update, User, department_id: user.company_id
        can :delete, User, department_id: user.company_id
        can :import, User
        can :batch_action, User
        can :reset_password, User, department_id: user.company_id

      elsif user.role.sign == "admin" #全部数据权限
        can :manage, User
      end
    end

    # Public
    # 未登录用户权限
    can :info, User

    # 省市区：所有登录用户可读，管理需 admin
    can :read, Province
    can :read, City
    can :read, County

    # 单号规则：登录用户可读配置、生成、预览；admin 可管理
    can [:read, :generate, :preview], DocNumberRule if user.present?
    

    def roles_for_anonymous
      cannot :manage, :all
      # basic_read_only
    end
  end
end

# Define abilities for the user here. For example:
#
#   return unless user.present?
#   can :read, :all
#   return unless user.admin?
#   can :manage, :all
#
# The first argument to `can` is the action you are giving the user
# permission to do.
# If you pass :manage it will apply to every action. Other common actions
# here are :read, :create, :update and :destroy.
#
# The second argument is the resource the user can perform the action on.
# If you pass :all it will apply to every resource. Otherwise pass a Ruby
# class of the resource.
#
# The third argument is an optional hash of conditions to further filter the
# objects.
# For example, here the user can only update published articles.
#
#   can :update, Article, published: true
#
# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
# 