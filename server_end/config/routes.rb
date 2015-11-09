Rails.application.routes.draw do
  resource :calculations do
    post 'reputation_algorithms', to:'calculations#reputation_algorithms'
  end
end
