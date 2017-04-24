Rails.application.routes.draw do
  resources :teams do
    resources :players
  end

  root 'welcome#index'
end
