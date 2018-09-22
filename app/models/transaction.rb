class Transaction < ApplicationRecord
  belongs_to :invoice
  belongs_to :transaction_category
  has_one :user, through: :invoice

  def as_json(_opt = nil)
    super({
          only: [
              :id, :name, :description,
              :invoice_id, :transaction_category_id
          ],
          include: {
              invoices: {
                  only: [:id, :name, :description, :value]
              },
              transaction_categories: {
                  only: [:id, :name]
              }
          }
      }.merge(_opt || {})
    )
  end
end
