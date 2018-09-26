class Invoice < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  attr_accessor :value
  after_create :create_first_transaction_from_value
  before_destroy :check_if_user_has_another_one

  validates :name, presence: true

  def as_json(_opt = nil)
    return super(_opt) if _opt
    super({
              only: [:id, :name, :description],
              methods: :value,
              include: {
                  transactions: {
                      only: [:id, :name, :description, :value,
                             :invoice_id, :transaction_category_id]
                  }
              }
          }
    )
  end

  def value
    self.transactions.sum(:value) || 0
  end

  private

  def create_first_transaction_from_value
    Transaction.create!(name: 'First transaction', invoice: self, value: @value) unless @value.nil?
  end

  def check_if_user_has_another_one
    if self.user.invoices.count == 1
      errors.add :base, 'User must have at least one invoice'
      throw(:abort)
    end
    true
  end
end
