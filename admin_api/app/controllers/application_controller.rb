class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_ip


  def set_current_ip
    @current_ip =eval("#{Setting.get_request_ip}") rescue ''
  end


  
end
