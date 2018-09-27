class CreditsController < ApplicationController
  include Concerns::ResourceController
  before_action :set_author, only: :create
  before_action :resource, only: %i[show destroy
                                    confirm_credit confirm_money_transfer pay
                                    reject_payment confirm_payment forgive]

  def confirm_credit
    @resource.confirm_credit!
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot confirm credit')
  end

  def confirm_money_transfer
    @resource.confirm_money_transfer
    value = @resource.value
    author_invoice = @resource.author.invoices.first
    issued_invoice = @resource.issued.invoices.first
    @resource.value = value + @resource.fee.to_f
    ActiveRecord::Base.transaction do
      @resource.save!
      Transaction.create!(name: 'Credit from user', invoice: issued_invoice, value: value)
      Transaction.create!(name: 'Credit to user', invoice: author_invoice, value: -value)
    end
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot confirm money transfer')
  end

  def pay
    @resource.pay
    @resource.pending_money = params[:credit][:value].to_f
    @resource.save!
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot pay')
  end

  def reject_payment
    @resource.reject_payment
    @resource.pending_money = nil
    @resource.save!
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot reject payment')
  end

  def confirm_payment
    pending_money = @resource.pending_money
    @resource.value -= pending_money
    @resource.pending_money = nil
    if @resource.value == 0
      if @resource.expired_at && @resource.expired_at < DateTime.now
        @resource.confirm_late_payment
      else
        @resource.confirm_payment
      end
    else
      @resource.confirm_part_payment
    end
    author_invoice = @resource.author.invoices.first
    issued_invoice = @resource.issued.invoices.first
    ActiveRecord::Base.transaction do
      @resource.save!
      Transaction.create!(name: 'Pay for credit', invoice: issued_invoice, value: -pending_money)
      Transaction.create!(name: 'Pay for credit', invoice: author_invoice, value: pending_money)
    end
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot confirm payment')
  end

  def forgive
    @resource.forgive!
    render_resource(@resource)
  rescue
    render_resource(@resource, errors: 'Cannot forgive')
  end

  private

  def set_author
    @resource.author = current_user
  end

  def permitted_attributes
    @permitted_attributes = %w( description issued_id value fee expired_at )
  end
end
