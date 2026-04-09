# README


### 生成模型

rails g model company
logo:string parent_id:integer abbr:string name:string credit_code:string legal_name:string status_id:integer reg_date:date reg_capital:string reg_address:string company_type_id:integer contact:string email:string business_scope:text industry_id:integer business_reg_number:string business_term:string approval_date:date region_id:integer organization_code:string user_id:integer

### 生成接口

rails g api:v1:scaffold_controller Company --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes logo,parent_id,abbr,name,credit_code,legal_name,status_id,reg_date,reg_capital,reg_address,company_type_id,contact,email,business_scope,industry_id,business_reg_number,business_term,approval_date,region_id,organization_code,user_id