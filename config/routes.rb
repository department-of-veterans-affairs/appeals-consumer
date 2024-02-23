Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "health-check", to: "health_checks#show"

  # Defines the root path route ("/")
  # root "posts#index"
end
