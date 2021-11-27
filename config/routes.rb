# frozen_string_literal: true

Rails.application.routes.draw do
  mount ActionCable.server => '/history_update'

  namespace :api do
    namespace :v1 do
      resources :accounts
      resources :assets, only: %i[show]
      resources :totals, only: %i[index]

      namespace :users do
        post 'authenticate'
      end
      delete 'users', to: 'users#destroy'
      resources :users, only: %i[create]
    end
  end
end
