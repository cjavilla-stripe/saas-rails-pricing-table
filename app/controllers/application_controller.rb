class ApplicationController < ActionController::Base

  def require_subscription!
    unless current_user.subscribed?
      redirect_to pricing_path
    end
  end
end
