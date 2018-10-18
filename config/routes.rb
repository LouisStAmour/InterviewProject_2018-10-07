Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :encrypted_strings, param: :token

  # POST /data_encrypting_keys/rotate
  post 'data_encrypting_keys/rotate'
  # GET  /data_encrypting_keys/rotate/status
  get 'data_encrypting_keys/rotate/status', to: 'data_encrypting_keys#rotate_status'
end
