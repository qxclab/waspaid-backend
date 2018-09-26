class Ability
  include CanCan::Ability

  def initialize(user)
    return cannot :read, :all unless user
    cannot :read, :all
    can :read, User
    can :manage, User, id: user.id
    can :manage, [Invoice, TransactionCategory], user_id: user.id
    can :manage, Transaction do |x|
      x.user.id == user.id
    end
    can :create, Credit, author_id: user.id
    can :destroy, Credit, author_id: user.id
    can :read, Credit do |x|
      [x.author_id, x.issued_id].include? user.id
    end
    can %i[confirm_money_transfer reject_payment confirm_payment forgive], Credit, author_id: user.id
    can %i[confirm_credit pay], Credit, issued_id: user.id
  end
end
