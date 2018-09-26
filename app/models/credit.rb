class Credit < ApplicationRecord
  include AASM

  belongs_to :author, class_name: :User, foreign_key: :author_id
  belongs_to :issued, class_name: :User, foreign_key: :issued_id

  after_create :save_initial_value

  validates :value, numericality: {greater_than: 0}
  validate :author_not_equal_to_issuer

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
      transitions from: :confirmed, to: :money_transferred
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
    return super(_opt) if _opt
    super({
              only: [:id, :description, :state, :value, :initial_value, :fee, :pending_money, :expired_at],
              include: {
                  author: {
                      only: [:id, :email]
                  },
                  issued: {
                      only: [:id, :email]
                  }
              }
          }
    )
  end

  private

  def author_not_equal_to_issuer
    errors.add(:issued, 'can\'t be equal to author') if self.author == self.issued
  end

  def save_initial_value
    self.initial_value = self.value
    self.save
  end
end
