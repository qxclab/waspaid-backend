class Transaction < ApplicationRecord
  belongs_to :invoice
  belongs_to :transaction_category
  has_one :user, through: :invoice

  def as_json(_opt = nil)
    super({
          only: [
              :id, :name, :description, :value,
              :invoice_id, :transaction_category_id
          ],
          include: {
              invoice: {
                  only: [:id, :name, :description, :value]
              },
              transaction_category: {
                  only: [:id, :name]
              }
          }
      }.merge(_opt || {})
    )
  end
end
