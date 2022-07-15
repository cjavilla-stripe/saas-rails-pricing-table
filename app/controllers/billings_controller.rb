class BillingsController < ApplicationController
  def create
    portal = Stripe::BillingPortal::Session.create({
      customer: current_user.customer.stripe_id,
      return_url: dashboard_url
    })
    redirect_to portal.url, allow_other_host: true, status: :see_other
  end
end
