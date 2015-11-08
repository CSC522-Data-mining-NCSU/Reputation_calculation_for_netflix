Rails.application.routes.draw do
  resource :calculations do
    post 'lauw_algorithm', to:'calculations#lauw_algorithm'
  end
end
