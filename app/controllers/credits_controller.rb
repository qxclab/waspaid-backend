class CreditsController < ApplicationController
  include Concerns::ResourceController
  before_action :set_author, only: :create
  before_action :resource, only: %i[show update destroy
                                    confirm_credit confirm_money_transfer pay
                                    reject_payment confirm_payment forgive]

  def confirm_credit
    render_resource(@resource)
  end

  def confirm_money_transfer
    render_resource(@resource)
  end

  def pay
    render_resource(@resource)
  end

  def reject_payment
    render_resource(@resource)
  end

  def confirm_part_payment
    render_resource(@resource)
  end

  def confirm_payment
    render_resource(@resource)
  end

  def forgive
    render_resource(@resource)
  end

  private

  def set_author
    @resource.author = current_user
  end

  def permitted_attributes
    @permitted_attributes = %w( description issued_id value fee expired_at )
  end
end
