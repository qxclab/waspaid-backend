class Invoice < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  attr_accessor :value
  after_create :create_first_transaction_from_value

  validates :name, presence: true

  def as_json(_opt = nil)
    super({
          only: [:id, :name, :description],
          methods: :value,
          include: {
              transactions: {
                  only: [:id, :name, :description, :value,
                         :invoice_id, :transaction_category_id]
              }
          }
      }.merge(_opt || {})
    )
  end

  def value
    self.transactions.sum(:value) || 0
  end

  private

  def create_first_transaction_from_value
    Transaction.create!(name: 'First transaction', invoice: self, value: @value) unless @value.nil?
  end
end
