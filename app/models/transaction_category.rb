class TransactionCategory < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :name, presence: true

  def as_json(_opt = nil)
    super({
          only: [:id, :name],
          include: {
              transactions: {
                  only: [:id, :name, :description, :value,
                         :invoice_id, :transaction_category_id]
              }
          }
      }.merge(_opt || {})
    )
  end
end
