class Credit < ApplicationRecord
  include AASM

  belongs_to :author, class_name: :User, foreign_key: :author_id
  belongs_to :issued, class_name: :User, foreign_key: :issued_id

  validates :value,  numericality: { greater_than: 0 }

  aasm column: :state do
    state :issued, :initial => true
    state :confirmed
    state :money_transferred
    state :pay_failed
    state :pay_pending
    state :paid_partly
    state :paid
    state :late_paid
    state :forgiven

    event :confirm_credit do
      transitions from: :issued, to: :confirmed
    end

    event :confirm_money_transfer do
      transitions from: :confirmed, to: :transfer_money
    end

    event :pay do
      transitions from: %i[money_transferred paid_partly], to: :pay_pending
    end

    event :reject_payment do
      transitions from: :pay_pending, to: :pay_failed
    end

    event :confirm_part_payment do
      transitions from: :pay_pending, to: :paid_partly
    end

    event :confirm_payment do
      transitions from: :pay_pending, to: :paid
    end

    event :confirm_late_payment do
      transitions from: :pay_pending, to: :late_paid
    end

    event :forgive do
      transitions from: %i[transfer_money pay_failed pay_pending paid_partly], to: :forgiven
    end
  end


  def as_json(_opt = nil)
    super({
          only: [:id, :description, :state, :value, :fee, :expired_at],
          include: {
              author: {
                  only: [:id, :email]
              },
              issued: {
                  only: [:id, :email]
              }
          }
      }.merge(_opt || {})
    )
  end
end
