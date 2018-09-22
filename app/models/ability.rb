class Ability
  include CanCan::Ability

  def initialize(user)
      user ||= User.new
      cannot :read, :all
      can :manage, [Invoice, TransactionCategory], user_id: user.id
      can :manage, Transaction do |x|
        x.user.id == user.id
      end
  end
end
