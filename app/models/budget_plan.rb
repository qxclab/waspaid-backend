class BudgetPlan < ApplicationRecord
  belongs_to :user

  enum budget_item_type: %i[ expenses incomes deposit ]
  enum transition_type:  %i[ stable termorary once ]
  
  validates :name, presence: true

  def as_json(_opt = nil)
    return super(_opt) if _opt
    super({
              only: %i[id name value budget_item_type transition_type at_date exact_date]
          }
    )
  end

  def self.calculate_daily_money(user)
    current_time_utc = Time.now.utc
    days_to_the_end_of_month = (current_time_utc.day..current_time_utc.end_of_month.day).count
    transactions_sum = Transaction.where(user: user, created_at: current_time_utc.beginning_of_month..current_time_utc.end_of_month).sum(:value)

    {
        data: {
            days_to_the_end_of_month: days_to_the_end_of_month,
            transactions_sum: transactions_sum
        }
    }
  end
end
