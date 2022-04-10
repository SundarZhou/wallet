Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  Rails.application.routes.draw do
    resource :accounts, only: [:create]
    post "/login", to: "accounts#login"
    get "/check", to: "accounts#check"
    get "/histories", to: "accounts#histories"
    post "/withdraw", to: "accounts#withdraw"
    post "/deposit", to: "accounts#deposit"
    post "/transfer", to: "accounts#transfer"
  end
end
