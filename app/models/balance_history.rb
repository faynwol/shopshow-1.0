class BalanceHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_balance

  validates_numericality_of :amount

  # 类型: [消费 充值 退款 提现]
  validates_inclusion_of :history_type, in: %w( consume recharge refund withdraw )

end
