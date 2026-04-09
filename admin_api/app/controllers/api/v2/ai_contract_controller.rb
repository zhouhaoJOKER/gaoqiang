class Api::V2::AiContractController < ActionController::API

  # skip_before_action :verify_authenticity_token, only: [:audit_contract]


  # 合同审完成后回调接口
  # post "api/v2/audit_contract"
  def audit_contract
    uuid = params["uuid"]
    if uuid.present?
      audit_contract  = AuditContract.find_by(uuid: uuid)
      if audit_contract.present?
        audit_contract.update(
          result: params[:data],
          result_at: Time.now,
          status: "完成",
        )
        render json: {code: 200, success: 1 , msg: "操作完成。"}

      else
        render json: {code: 404, success: 0 , msg: "记录不存在"}
      end
    else
      render json: {code: 500, success: 0 , msg: "参数错误"}
    end
    
  end
   
  private 
    def user_params
      params.permit(:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :nickname, :name, :phone, :approved, :uuid, :code, :sex, :marriage, :cardnum, :brondate, :department_id, :post_id, :hire_date, :fire_date, :director_id, :role_id, :status, :avatar, :remark, :whitelists, :change_passowrd, :company_id, :current_company_id)
    end
    
end
