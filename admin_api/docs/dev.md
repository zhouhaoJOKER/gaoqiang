# dev 

产品type_id

原料 50
纸箱100 

### 生成模型


rails g model company
logo:string parent_id:integer abbr:string name:string credit_code:string legal_name:string status_id:integer reg_date:date reg_capital:string reg_address:string company_type_id:integer contact:string email:string business_scope:text industry_id:integer business_reg_number:string business_term:string approval_date:date region_id:integer organization_code:string user_id:integer

### 生成接口

rails g api:v1:scaffold_controller Pm::Portfolio --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes code,name,status_id,start_date,end_date,is_star,manager_id,description,degree,labels,custom_fields,user_id,company_id

name,status_id,start_date,end_date,is_star,manager_id,description,user_id


rails g model property sign:string:index parent_id:integer name:string py:string sort:integer color:string  is_open:boolean  user_id:integer

rails g api:v1:scaffold_controller Pm::Portfolio --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes code,name,status_id,start_date,end_date,is_star,manager_id,description,degree,labels,custom_fields,user_id,company_id

## 产品模块

rails g model mat/product labels:json custom_fields:json user_id:integer updater_id:integer company_id:integer:index  name:string logo:string code:string py:string pinyin:string  type_id:integer:index  category_id:integer:index  price:decimal cost_price:decimal market_price:decimal  description:text uom_id:integer uom_po_id:integer  sale_tax_id:integer purchase_tax_id:integer is_sale:boolean is_purchase:boolean  is_manufacture:boolean is_stock:boolean is_active:boolean  --force 

rails g model mat/combo user_id:integer updater_id:integer company_id:integer:index  name:string min:integer max:integer price:decimal discount:integer description:text  --force 

rails g model mat/combo_option combo_id:integer product_id:integer  name:string  price:decimal  extra_price:decimal  --force 


rails g model mat/attribute user_id:integer updater_id:integer company_id:integer:index  name:string   py:string is_variant:boolean display_type:string  sort:float  --force 

rails g model mat/value user_id:integer updater_id:integer attribute_id:integer:index  name:string   color:string extra_price:decimal  sort:float  --force 

rails g model mat/attribute_line  user_id:integer  product_id:integer:index attribute_id:integer:index  name:string values:json value_ids:json  sort:float   --force 

rails g model mat/item  labels:json custom_fields:json user_id:integer updater_id:integer company_id:integer:index  name:string logo:string code:string py:string pinyin:string barcode:string type_id:integer:index  category_id:integer:index  price:decimal cost_price:decimal market_price:decimal  description:text uom_id:integer uom_po_id:integer  sale_tax_id:integer purchase_tax_id:integer is_sale:boolean is_purchase:boolean  is_manufacture:boolean is_stock:boolean is_active:boolean product_id:integer:index value_id:integer sku:string weight:decimal volume:decimal qty_onhand:integer qty_available:integer qty_incoming:integer qty_outgoing:integer  --force 

## 项目模块
rails g model pm/member  record_id:integer  record_type:string user_id:integer role_id:integer  joined_at:datetime

rails g model  activity status_id:integer content:text parent_id:integer record_id:integer  record_type:string  user_id:integer mention_ids:json file_urls:json

rails g model  pm/project  portfolio_id:integer parent_id:integer code:string name:string py:string pinyin:string  logo:string status_id:integer source_id:integer  start_date:date end_date:date is_star:boolean manager_id:integer  description:text degree:json labels:json custom_fields:json user_id:integer updater_id:integer company_id:integer:index is_public:boolean   is_archived:boolean is_suspended:boolean suspend_at:datetime suspender_id:integer ancestry:string:index

模板
rails g model  pm/template name:string  description:text logo:string

阶段 
rails g model pm/stage project_id:integer:index name:string sort:integer task_count:integer is_archived:boolean  user_id:integer updater_id:integer

rails g model pm/task  project_id:integer:index stage_id:integer:index category_id:integer  status_id:integer   name:string   py:string   priority_id:integer sort:integer  labels:json custom_fields:json  due_at:datetime done_at:datetime is_star:boolean is_public:boolean is_done:boolean  executor_id:integer  user_id:integer updater_id:integer description:text plan_time:decimal real_time:decimal progress:integer  ancestry:string:index



工时
rails g model pm/timesheet kind:integer project_id:integer:index date:date task_id:integer:index time:decimal user_id:integer updater_id:integer


文件
rails g model pm/file  project_id:integer:index parent_id:integer py:string   name:string file_size:integer color:string user_id:integer  updater_id:integer file_count:integer is_public:boolean kind:integer  ancestry:string:index

文档 
rails g model pm/document  project_id:integer:index parent_id:integer kind:integer name:string  py:string  content:text user_id:integer updater_id:integer is_public:boolean  ancestry:string:index

## pm

rails g model pm/portfolio code:string name:string status_id:integer start_date:date end_date:date is_star:boolean manager_id:integer description:text degree:json labels:json custom_fields:json user_id:integer company_id:integer:index 

## 安全设置
开启安全设置 open_security_certificate
黑名单IP
白名单IP
开启访问时间限制
open_visit_restriction
allow_visit_start
allow_visit_end


## 权限分为 4级别
全部 超级管理员
公司 以当前用户公司id为基准  company_id
部门 以当前用户部门为基准 department_id 
自己 以自己的记录为基准 user_id

rails generate job CheckDigitJob --queue default


VISUAL="code --wait" bin/rails credentials:edit    

mission_control:
  http_basic_auth_user: admin
  http_basic_auth_password: admin@2020

```bash
require 'chinese_pinyin'

Pinyin.t('中国')  => "zhong guo"
Pinyin.t('你好world') => "ni hao world"
Pinyin.t('中国', splitter: '-') => "zhong-guo"
Pinyin.t('中国', splitter: '') => "zhongguo"
Pinyin.t('中国', tone: true) => "zhong1 guo2"
Pinyin.t('中国', tonemarks: true) => "zhōng guó"
Pinyin.t('北京') { |letters| letters[0].upcase } => 'BJ'
Pinyin.t('北京') { |letters, i| letters[0].upcase if i == 0 } => 'B'
```


## record command

rails d scaffold demo 
rails g scaffold demo name:string code:string file:string decr_file:string 
