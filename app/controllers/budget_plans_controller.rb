class BudgetPlansController < ApplicationController
  include Concerns::ResourceController
  include Concerns::ResourceBelongsToUser

  def calculate_daily_money
    render_resource(BudgetPlan.calculate_daily_money(current_user))
  end
end
