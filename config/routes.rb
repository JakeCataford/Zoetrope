Rails.application.routes.draw do
  root "gifs#new"
  resources :gifs do
    member do
      get "compose"
      get "progress"
      get "validate"
    end
  end
end
