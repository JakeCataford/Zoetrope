Rails.application.routes.draw do
  root "gifs#new"
  resources :gifs do
    member do
      get "compose"
      get "progress"
      get "validate"
      get "aborted"
      post "queue"
    end
  end
end
