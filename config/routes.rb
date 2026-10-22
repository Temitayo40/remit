Rails.application.routes.draw do

  resource :session                                    
  resource :registration, only: %i[ new create ]        
  resources :passwords, param: :token

  #  never deleted, because payment history will point at them.
  resources :vehicles, except: :destroy
  resources :drivers, except: :destroy

  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letters" if Rails.env.development?

  root "dashboard#show"
end
