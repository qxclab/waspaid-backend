class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #  :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :registerable, :trackable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JWTBlacklist

  has_many :invoices, dependent: :destroy
  has_many :transaction_categories, dependent: :destroy
  has_many :transactions, through: :invoices, dependent: :destroy

  validates_uniqueness_of :email

  def as_json(_opt = nil)
    super({
          only: [:id, :email],
          include: {
          invoices: {
              only: [:id, :name, :description, :value]
          },
          transaction_categories: {
              only: [:id, :name]
          },
          transactions: {
              only: [:id, :name, :description,
                     :invoice_id, :transaction_category_id]
          }
        }
      }.merge(_opt || {})
    )
  end
end
