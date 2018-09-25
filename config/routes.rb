Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
                 sign_in: 'login',
                 sign_out: 'logout',
                 registration: 'signup'
             },
             controllers: {
                 sessions: 'sessions',
                 registrations: 'registrations'
             }

  resources :users, only: :index
  resources :invoices
  resources :transaction_categories
  resources :transactions
  resources :credits, except: :update do
    member do
      post 'confirm_credit'
      post 'confirm_money_transfer'
      post 'pay'
      post 'reject_payment'
      post 'confirm_payment'
      post 'forgive'
    end
  end
  root to: 'info#index'
end
