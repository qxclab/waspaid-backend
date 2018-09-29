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
  has_many :budget_plans, dependent: :destroy
  has_many :issued, class_name: :Credit, foreign_key: :issued_id, dependent: :destroy
  has_many :issuer, class_name: :Credit, foreign_key: :author_id, dependent: :destroy

  after_create :create_cash_invoice

  validates_uniqueness_of :email
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :invoices, presence: true, if: Proc.new {|x| x.id.present?}
  validates :email, :password, presence: true

  def as_json(_opt = nil)
    return super(_opt) if _opt
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
                      only: [:id, :description, :state, :value, :initial_value, :fee, :pending_money, :expired_at],
                      include: {
                          author: {
                              only: [:id, :email]
                          }
                      }
                  },
                  issuer: {
                      only: [:id, :description, :state, :value, :initial_value, :fee, :pending_money, :expired_at],
                      include: {
                          issued: {
                              only: [:id, :email]
                          }
                      }
                  },
                  budget_plans: {
                      only: %i[id name value budget_item_type transition_type at_time exact_date]
                  }
              }
          }
    )
  end

  private

  def create_cash_invoice
    Invoice.create!(name: 'Cash', user: self, description: 'This is example invoice for cash tracking', value: 0.0)
  end
end
