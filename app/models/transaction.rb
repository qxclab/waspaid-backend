class Transaction < ApplicationRecord
  belongs_to :invoice
  belongs_to :transaction_category, optional: true
  has_one :user, through: :invoice

  validates :name, :value, presence: true

  def as_json(_opt = nil)
    return super(_opt) if _opt
    super({
              only: [
                  :id, :name, :description, :value,
                  :invoice_id, :transaction_category_id
              ],
              include: {
                  invoice: {
                      only: [:id, :name, :description],
                      methods: :value
                  },
                  transaction_category: {
                      only: [:id, :name]
                  }
              }
          }
    )
  end
end
