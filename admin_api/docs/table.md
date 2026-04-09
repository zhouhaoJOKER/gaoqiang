
# tables

## 基础模块 base 

**省（provinces）**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | integer | 行政区划码（唯一） |
| name | string | 省名称 |
| py | string | 拼音/检索 |

| 接口 | 方法 | 路由 | 说明 |
|------|------|------|------|
| 列表 | GET | /api/v1/provinces | 省列表 |
| 详情 | GET | /api/v1/provinces/:id | 单省详情 |
| 新增 | POST | /api/v1/provinces | 新增省 |
| 修改 | PUT | /api/v1/provinces/:id | 修改省 |
| 删除 | DELETE | /api/v1/provinces/:id | 删除省 |



**市（cities）**

| 字段 | 类型 | 说明 |
|------|------|------|
| province_id | references | 省（关联 provinces） |
| code | integer | 行政区划码（唯一） |
| name | string | 市名称 |
| py | string | 拼音/检索 |

| 接口 | 方法 | 路由 | 说明 |
|------|------|------|------|
| 列表 | GET | /api/v1/cities | 市列表（可带 ?province_id=） |
| 详情 | GET | /api/v1/cities/:id | 单市详情 |
| 新增 | POST | /api/v1/cities | 新增市 |
| 修改 | PUT | /api/v1/cities/:id | 修改市 |
| 删除 | DELETE | /api/v1/cities/:id | 删除市 |



**县/区（counties）**

| 字段 | 类型 | 说明 |
|------|------|------|
| city_id | references | 市（关联 cities） |
| code | integer | 行政区划码（唯一） |
| name | string | 县/区名称 |
| py | string | 拼音/检索 |

| 接口 | 方法 | 路由 | 说明 |
|------|------|------|------|
| 列表 | GET | /api/v1/counties | 县/区列表（可带 ?city_id=） |
| 详情 | GET | /api/v1/counties/:id | 单县/区详情 |
| 新增 | POST | /api/v1/counties | 新增县/区 |
| 修改 | PUT | /api/v1/counties/:id | 修改县/区 |
| 删除 | DELETE | /api/v1/counties/:id | 删除县/区 |

**属性（properties）**

| 字段 | 类型 | 说明 |
|------|------|------|
| sign | string | 标识/编码（有索引） |
| parent_id | integer | 父级属性 ID |
| name | string | 属性名称 |
| py | string | 拼音/检索 |
| sort | integer | 排序 |
| color | string | 颜色 |
| is_open | boolean | 是否启用 |
| abbr | string | 缩写 |
| user_id | integer | 创建人 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |





rails g model audit_list audit_contract_id:integer  sn:integer  serial_number:string  risk_clause:string  risk_level:string  legal_advice:string  reply:string user_id:integer

audit_contract:


rails g model audit_contract parent_id:integer:index version:string uuid:string:index part_a:string part_b:string contract_number:string project_name:string department_id:integer user_id:integer is_realtime:boolean status:string file:string result:json result_at:string result_file:string remark:text

uuid: 标识id 
part_a: 甲方
part_b: 乙方
contract_number: 合同编号
project_name: 项目名称
department_id: 部门
user_id: 创建人
is_realtime: 是否实时
status: 状态
file: 文件
result: 审核结果
result_at: 完成时间
result_file: 结果文件


departments
menus
nodes
users


## users 
code:string 
name:string
uuid:string
sex:string 
bron_date:date
marriage:string
phone:string
cardnum:string
department_id:integer
post_id:integer
hire_date:date
fire_date:date
director_id:integer 
role_id:integer
status:integer


## 部门

rails g model department code:string name:string parent_id:integer parent_code:string status:integer manager_id:integer  user_id:integer remark:string

## 角色


rails g model role code:string name:string category:integer  sort:integer describe:string roles:text  user_id:integer 

    t.string "name", comment: "角色名"
    t.integer "category", comment: "角色类别"
    t.text "roles", comment: "角色列表"

## 权限

rails g model permissions code:string name:string category:integer   act:string ctrl:string sign:string core:boolean  user_id:integer 


## 节点

rails g model node code:string name:string type:string root_id:integer parent_id:integer is_public:boolean file:string  decrypt_file:string info:text  remark:string   creater_id:integer updater_id:integer



## 菜单


rails g model menu path:string name:string redirect:string icon:string title:string is_link:boolean is_hide:boolean  is_full:boolean  is_affix:boolean is_keeplive:boolean    remark:string user_id:string 



{
  "path": "/permission",
  "name": "permission",
  "redirect": "/permission/menu/index",
  "meta": {
    "icon": "HomeFilled",
    "title": "权限管理",
    "isLink": "",
    "isHide": false,
    "isfull": false,
    "isAffix": true,
    "iskeeplive": true
  }
}




表名	表名注释	后台字段名	显示字段名	字段类型	字段长度	是否主键	是否外键	是否自增	是否允许为空	备注
It_EMPLOYEE	员工信息表	ID	员工编号	varchar	30	是	否	否	否	
		EMPNAME	员工姓名	varchar	60	否	否	否	是	
		SEX	性别	varchar	20	否	否	否	是	M：男   F：女
		BORNDATE	出生日期	datetime		否	否	否	是	
		MARRIAGE	婚姻	varchar	20	否	否	否	是	Y：已婚  N：未婚  O：其他  L：离异  S：丧偶  B：保密
		NATIVEPLACE	籍贯	varchar	200	否	否	否	是	
		PHONE	联系电话	varchar	15	否	否	否	是	
		EMAIL	邮箱	varchar	150	否	否	否	是	
		CARDNUM	身份证号	varchar	30	否	否	否	是	
		departmentCode	部门编号	varchar	30	否	是	否	是	
		PostName	岗位	varchar	150	否	否	否	是	
		HIREDATE	入职日期	datetime		否	否	否	否	
		FIREDATE	离职日期	varchar	150	否	否	否	是	
		directorId	直接主管编号	varchar	30	否	否	否	是	
		StopSalaryFlag	员工状态	int		否	否	否	否	0：在职   1：离职  2：待入职
		status	同步标识	int		否	否	否	否	0：新增或修改   1：删除
		updDatetime	更新时间	datetime		否	否	否	否	
		chenbentype	行政级别	varchar	150					汉字
		HTendDate	合同期满日期	varchar	50					yyyy-MM-dd
										
It_DEPARTMENT	部门结构表	DEPARTMENTCODE	部门编号	varchar	30	是	否	否	否	
		DEPARTMENTNAME	部门名称	varchar	50	否	否	否	否	
		supDepartment	上级部门编码	varchar	30	否	否	否	是	
		IsSubsector	是否为OA部门分部	int		否	否	否	否	0：否   1：是
		subsectorCode	所属分部编码	varchar	30	否	否	否	否	
		oaDeptCode	OA部门编码	varchar	50	否	否	否	是	
		status	同步标识	int		否	否	否	否	0：新增或修改   1：删除
		updDatetime	更新时间	datetime		否	否	否	否	