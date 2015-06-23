require 'domain_constraint'

FiLabInfographics::Application.routes.draw do

  constraints DomainConstraint.new('status.lab') do
    get '/',  to: "welcome#status", as: 'status_root'
  end

  constraints DomainConstraint.new('historical.lab') do
    get '/',  to: "welcome#historical", as: 'historical_root'
  end

  constraints DomainConstraint.new('infographic.lab') do
    get '/',  to: "welcome#info", as: 'info_root'
  end
 
  root :to => 'welcome#info'
  
  mount FiLabApp::Engine => "/"#"/fi_lab_app"
  
#  get "welcome/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  

#   devise_for :users, :class_name => "FiLabApp::User", :module => :devise, :controllers => { :omniauth_callbacks => "fi_lab_app/users/omniauth_callbacks" }#, :sessions => "fi_lab_app/sessions" }
#   get "welcome/index"
#   get "welcome/protected"
#   get "welcome/role"
#   get "welcome/error"

  # You can have the root of your site routed with "root"
 # root 'welcome#index'
  
  get '/info', to: 'welcome#info'
  get '/status', to: 'welcome#status'
  get '/historical', to: 'welcome#historical'
#  get '/nam' => redirect('http://138.4.47.33:5000/')
  
  scope "/api/v1" do
    scope "/region" do
      get "/" => "region#renderRegions"      
      get "/totData"  => "region#renderRegionsTotData"
      get "/vm" => "region#renderVms"
      get "/services" => "region#renderServices" 
      get "/services/:nodeId" => "region#renderServicesForRegion"
      get "/historical/:nodeId" => "region#renderHistoricalForRegion"
      get "/list" => "region#renderRegionIdListFromDb"
      get "/:nodeId"  => "region#renderRegionsDataForRegion"
#      options "/list" => "region#getRegionIdList"
#       get ":region_id" => "region#getRegion"
#       get ":region_id/vm" => "region#getVMs"
#       get ":region_id/vm/:vm_id" => "region#getVM"
    end
    scope "/jira" do
      post "/issue" => "jira#createIssue"
    end
  end
  
  
#   devise_scope :user do
# # get '/users/sign_in', :to => 'sessions#new', :as => :new_user_session
#     get 'users/:id', :to => 'users#show', :as => :user
# # get '/logout' => 'devise/sessions#destroy', :as => :destroy_user_session
#   end


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
