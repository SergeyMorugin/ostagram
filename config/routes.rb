Rails.application.routes.draw do
  resources :styles
  match '/styles/:id/mark', to: 'styles#mark', via: 'put'

  resources :contents
  get 'admin_pages/main'
  get 'admin_pages/images'
  get 'admin_pages/users'
  get 'admin_pages/startbot'
  get 'admin_pages/startprocess'
  get 'admin_pages/unregworkers'
  get 'admin_pages/update_queue_status'
  match '/admin_pages/update_queue_status', to: 'admin_pages#update_queue_status', via: 'put'
  match '/admin_pages/update_style_status', to: 'admin_pages#update_style_status', via: 'put'
  match '/admin_pages/update_content_status', to: 'admin_pages#update_content_status', via: 'put'
  match '/admin_pages/delete_queue', to: 'admin_pages#delete_queue', via: 'put'

  devise_for :clients
  resources :queue_images
  match '/queue_images/:id/visible', to: 'queue_images#visible', via: 'put'
  match '/queue_images/:id/hidden', to: 'queue_images#hidden', via: 'put'
  match '/queue_images/:id/like', to: 'queue_images#like_image', via: 'put'
  match '/queue_images/:id/unlike', to: 'queue_images#unlike_image', via: 'put'

  get 'static_pages/lenta', as: 'user_root'

  match '/about', to: 'static_pages#about', via: 'get'
  match '/home', to: 'static_pages#home', via: 'get'
  match '/error', to: 'static_pages#error', via: 'get'
  match '/lenta', to: 'static_pages#lenta', via: 'get'
  #match '/admin', to: 'admin_pages#error', via: 'get'


  root "static_pages#home"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
