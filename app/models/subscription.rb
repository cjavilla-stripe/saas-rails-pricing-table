# == Schema Information
#
# Table name: subscriptions
#
#  id              :bigint           not null, primary key
#  customer_id     :bigint           not null
#  stripe_id       :string
#  stripe_price_id :string
#  status          :string
#  quantity        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Subscription < ApplicationRecord
  belongs_to :customer
  has_one :user, through: :customer

  scope :active, -> { where(status: ['active', 'trialing']) }
end
