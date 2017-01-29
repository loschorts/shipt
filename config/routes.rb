Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  namespace :api, defaults: {format: :json} do

		resources :products, only: [:index] do 
			get :sales, on: :collection
		end

		resources :customers, only: [:show] do 
			get :orders, on: :member
		end
	end

end
