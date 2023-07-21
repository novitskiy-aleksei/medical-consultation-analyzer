Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post 'audio_records', to: 'audio_records#create'
  get 'analysed_transcription', to: 'transcription#show'
end
