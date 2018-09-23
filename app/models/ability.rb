class Ability
  include CanCan::Ability

  def initialize(user)
      user ||= User.new
      cannot :read, :all
      can :read, User
      can :manage, [Invoice, TransactionCategory], user_id: user.id
      can :manage, Transaction do |x|
        x.user.id == user.id
      end
      can :create, Credit, author_id: user.id
      can :destroy, Credit, author_id: user.id
      can :read, Credit do |x|
        x.author_id == user.id || x.issued_id == user.id
      end
      can %i[confirm_money_transfer reject_payment confirm_payment forgive], Credit, author_id: user.id
      can %i[confirm_credit pay], Credit, issued_id: user.id
  end
end
