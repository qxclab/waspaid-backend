class CreditsController < ApplicationController
  include Concerns::ResourceController
  before_action :set_author, only: :create
  before_action :resource, only: %i[show update destroy
                                    confirm_credit confirm_money_transfer pay
                                    reject_payment confirm_payment forgive]

  def confirm_credit
    if @resource.may_confirm_credit?
      @resource.confirm_credit!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot confirm credit')
    end
  end

  def confirm_money_transfer
    if @resource.may_confirm_money_transfer?
      @resource.confirm_money_transfer!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot confirm money transfer')
    end
  end

  def pay
    if @resource.may_pay?
      @resource.pay!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot pay')
    end
  end

  def reject_payment
    if @resource.may_reject_payment?
      @resource.reject_payment!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot reject payment')
    end
  end

  def confirm_payment
    if @resource.may_confirm_payment?
      @resource.confirm_payment!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot confirm payment')
    end
  end

  def forgive
    if @resource.may_forgive?
      @resource.forgive!
      render_resource(@resource)
    else
      render_resource(@resource, errors: 'Cannot forgive')
    end
  end

  private

  def set_author
    @resource.author = current_user
  end

  def permitted_attributes
    @permitted_attributes = %w( description issued_id value fee expired_at )
  end
end
