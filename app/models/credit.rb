class Credit < ApplicationRecord
  include AASM

  belongs_to :author, class_name: :User, foreign_key: :author_id
  belongs_to :issued, class_name: :User, foreign_key: :issued_id

  aasm column: :state do
    state :issued, :initial => true
    state :confirmed
    state :money_transferred
    state :paid_failed
    state :paid_partly
    state :paid_pending
    state :paid
    state :forgiven

    event :confirm do
      transitions from: :issued, to: :confirmed
    end

    event :transfer_money do
      transitions from: :confirmed, to: :transfer_money
    end

    event :pay do
      transitions from: :transfer_money, to: :paid_pending
    end

    event :reject_pay do
      transitions from: :transfer_money, to: :paid_failed
    end

    event :confirm_part_pay do
      transitions from: :transfer_money, to: :paid_partly
    end

    event :confirm_pay do
      transitions from: :transfer_money, to: :paid
    end

    event :forgive do
      transitions from: [:transfer_money, :paid_failed, :paid_pending], to: :forgiven
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
