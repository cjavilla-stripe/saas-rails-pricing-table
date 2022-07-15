class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_subscription!

  def show
  end
end
