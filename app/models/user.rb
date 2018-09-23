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
  has_many :issued, class_name: :Credit, foreign_key: :issued_id, dependent: :destroy
  has_many :issuer, class_name: :Credit, foreign_key: :author_id, dependent: :destroy

  validates_uniqueness_of :email

  def as_json(_opt = nil)
    super({
          only: [:id, :email],
          include: {
            invoices: {
                only: [:id, :name, :description],
                methods: :value
            },
            transaction_categories: {
                only: [:id, :name]
            },
            transactions: {
                only: [:id, :name, :description, :value,
                       :invoice_id, :transaction_category_id]
            },
            issued: {
                only: [:id, :description, :state, :value, :fee, :expired_at],
                include: {
                    author: {
                        only: [:id, :email]
                    }
                }
            },
            issuer: {
                only: [:id, :description, :state, :value, :fee, :expired_at],
                include: {
                    issued: {
                        only: [:id, :email]
                    }
                }
            }
        }
      }.merge(_opt || {})
    )
  end
end
