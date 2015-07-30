Rails.application.routes.draw do
  root "gifs#new"
  resources :gifs do
    member do
      get "compose"
      get "progress"
    end
  end
end
