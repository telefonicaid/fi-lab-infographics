FiLabInfographics::Application.routes.draw do
  get "welcome/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mount FiLabApp::Engine => "/fi_lab_app"

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  
  get '/status', to: 'welcome#status'
#  get '/nam' => redirect('http://138.4.47.33:5000/')
  
  scope "/api/v1" do
    scope "/region" do
      get "/" => "region#getRegions"
      get "/vm" => "region#getVms"
      get "/services" => "region#getServices"
#       get ":region_id" => "region#getRegion"
#       get ":region_id/vm" => "region#getVMs"
#       get ":region_id/vm/:vm_id" => "region#getVM"
    end
  end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
