Rails.application.routes.draw do
  require 'api'
  mount Shopshow::API => "/"
  require 'uszcn_api'
  mount Shopshow::Uszcn => '/'

  root to: 'welcome#index'
  post 'update_avatar', to: 'welcome#update_avatar'
  post 'update_recipient', to: 'welcome#update_recipient'

  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # 手机客户端
  namespace :mobile do
    resources :users, only: [:new, :create, :show] do
      collection do
        post :send_code
        post :verify_code
        post :check_name
        get :regist_succeed
      end
    end

    scope :shopping_cart do
      get :goods, to: 'shopping_cart#goods'
      post :update_item, to: 'shopping_cart#update_item'
      post :remove, to: 'shopping_cart#remove'
      post :remove_selected, to: 'shopping_cart#remove_selected'
      get :confirm, to: 'shopping_cart#confirm'
    end

    get :orders, to: 'orders#index'
    post :orders, to: 'orders#index'
    
  end  

  scope :jabber do
    post :prebind, to: 'jabber#prebind'
  end

  # 买手后台系统
  namespace :delivery do
    root to: 'index#dashboard'

    get 'login', to: 'sessions#new', as: 'login'    
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'

    resources :materials, only: [:create]

    resources :inbounds do
      member do
        get :query
      end
    end

    resources :orders do
      member do
        post :outbound       
        post :check_prepare_products 
        post :notify_carriage
        post :notify_tax        
      end
    end

    resources :outbounds do 
      member do
        get :query                        
      end                
    end

    resources :live_shows do
      member do        
        get :open
        get :close
        post :clearing_price
        get :shopping_list        
      end

      resources :products, shallow: true
      resources :messages, shallow: true
    end
  end

  get 'costco' => 'delivery/live_shows#preview_page'  
  # 运维后台
  namespace :cpanel do
    root to: 'live_shows#index'

    scope :faqs do
      get '1' => 'faqs#faq1'      
      get '2' => 'faqs#faq2'      
      get '3' => 'faqs#faq3'      
    end

    scope :trailer do
      get 'costco' => 'trailers#costco'      
      get 'next' => 'trailers#next'
    end

    resources :live_shows do
      member do
        get :products
        post :products
        get :close        
      end
      get :choose_material
    end

    resources :users

    resources :products do
      member do
        post :publish
      end
    end

    resources :materials, only: [:create]

    resources :orders do
      resources :items, only: [:index]
    end
  end
end
