# == Schema Information
#
# Table name: customers
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  stripe_id  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Customer < ApplicationRecord
  belongs_to :user
  has_many :subscriptions
end
