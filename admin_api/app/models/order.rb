class Order < ApplicationRecord
        require 'creek'

    # Order.read_file
    def self.read_file
 
        file = '/opt/fmanager/admin_api/tmp/1.xlsx'
        book = Creek::Book.new(file)
        sheet = book.sheets[2]
        cate = "原料"
        # datas = sheet.rows.each { |row|  row.values }
        # p datas

        result=[]
        sheet.rows.each do |row|
            row = row.values
            record = {}
            record["行号"]      = row[0]   # 示例值: "2023-001"
            record["商品代码"]  = row[1]   # 示例值: "MOTOR-IE3-4KW"
            record["名称"]      = row[2]   # 示例值: "三相异步电动机"
            record["数量"]      = row[3]   # 示例值: "25"
            record["K规格"]     = row[4]   # 示例值: "K-132M-4P"
            record["K系列"]     = row[5]   # 示例值: "高效节能系列"
            record["K中心高"]   = row[6]   # 示例值: "132mm"
            record["规格"]      = row[7]   # 示例值: "380V/50Hz"
            record["极数"]      = row[8]   # 示例值: "4极"
            record["K极数"]     = row[9]   # 示例值: "4P"
            record["马力"]      = row[10]  # 示例值: "5.5HP"
            record["功率"]      = row[11]  # 示例值: "4.0kW"
            record["K功率"]     = row[12]  # 示例值: "4000W"
            record["安装"]      = row[13]  # 示例值: "卧式安装"
            record["K安装"]     = row[14]  # 示例值: "B3"
            record["出线"]      = row[15]  # 示例值: "6线"
            record["K出线"]     = row[16]  # 示例值: "△/Y"
            record["电压"]      = row[17]  # 示例值: "380V±10%"
            record["K电压"]     = row[18]  # 示例值: "400V"
            record["频率"]      = row[19]  # 示例值: "50Hz"
            record["K频率"]     = row[20]  # 示例值: "50±1Hz"
            record["转速"]      = row[21]  # 示例值: "1450rpm"
            record["K转速"]     = row[22]  # 示例值: "1500r/min"
            record["绝缘"]      = row[23]  # 示例值: "F级"
            record["K绝缘"]     = row[24]  # 示例值: "CLASS-F"
            record["防护"]      = row[25]  # 示例值: "IP55"
            record["K防护"]     = row[26]  # 示例值: "IP55"
            record["能效"]      = row[27]  # 示例值: "一级"
            record["k能效"]     = row[28]  # 示例值: "IE3"
            record["要求"]      = row[29]  # 示例值: "需防潮处理"
            record["物料备注"]  = row[30]  # 示例值: "含不锈钢螺丝"
            record["其他"]      = row[31]  # 示例值: "紧急订单"
            record["单号"]      = row[32]  # 示例值: "PO-20230701-001"
            record["客户ID"]    = row[33]  # 示例值: "CUST-SHANGHAI-01"
            record["合同类别"]  = row[34]  # 示例值: "年度框架协议"
            record["类别"]  =  cate
            # result << record
            Order.create(record)
        end

        # p result




 
    end
    
end
