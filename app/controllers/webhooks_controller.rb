class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    # handle a stripe webhook with signature verification using stripe gem
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_signing_secret)
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { error: { message: e }}, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { error: { message: e }}, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'customer.subscription.updated'
      handle_subscription_updated(event)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event)
    else
      puts "Unhandled event type: #{event.type}"
    end
  end

  def handle_subscription_deleted(event)
    subscription = event.data.object
    sub = Subscription.find_by(stripe_id: subscription.id)
    sub.update!(
      status: subscription.status,
    )
  end

  def handle_subscription_updated(event)
    subscription = event.data.object
    subscription = Stripe::Subscription.retrieve(
      id: subscription.id,
      expand: ['items.data.price.product']
    )
    sub = Subscription.find_by(stripe_id: subscription.id)
    sub.update!(
      status: subscription.status,
      stripe_price_id: subscription.items.data.first.price.id,
      stripe_product_name: subscription.items.data.first.price.product.name,
      quantity: subscription.items.data.first.quantity
    )
  end

  def handle_checkout_session_completed(event)
    checkout_session = event.data.object
    customer = Customer.find_by(stripe_id: checkout_session.customer)
    if customer.nil?
      user = User.find_by(id: event.data.object.client_reference_id)
      customer = Customer.create!(
        user: user,
        stripe_id: checkout_session.customer
      )
    end

    subscription = Stripe::Subscription.retrieve(
      id: checkout_session.subscription,
      expand: ['items.data.price.product']
    )

    Subscription.create!(
      customer: customer,
      stripe_id: subscription.id,
      stripe_price_id: subscription.items.data.first.price.id,
      stripe_product_name: subscription.items.data.first.price.product.name,
      status: subscription.status,
      quantity: subscription.items.data.first.quantity
    )
  end
end
