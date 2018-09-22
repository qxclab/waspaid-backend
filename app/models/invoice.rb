class Invoice < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  def as_json(_opt = nil)
    super({
          only: [:id, :name, :description, :value],
          include: {
              transactions: {
                  only: [:id, :name, :description,
                         :invoice_id, :transaction_category_id]
              }
          }
      }.merge(_opt || {})
    )
  end
end
