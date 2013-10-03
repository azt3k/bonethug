UnitecGraduationMicrosite::Application.routes.draw do

  # You can have the root of your site routed with "root"
  # root 'application#index'
  root 'application#index'

  #errors
  match '/404', :to => 'errors#not_found', via: [:get, :post]
  match '/422', :to => 'errors#server_error', via: [:get, :post]
  match '/500', :to => 'errors#server_error', via: [:get, :post] 

end
