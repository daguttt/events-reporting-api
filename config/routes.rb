Rails.application.routes.draw do
  post "/events/:event_id/reports" => "reports#create", as: :event_reports
  # get "/events/:event_id/reports/get_history" => "reports#get_history", as: :event_reports_history
  put "/events/:event_id/reports/schedule" => "reports#schedule", as: :event_reports_schedule
  get "/record/logs" => "reports#get_logs", as: :event_reports_logs
  get "/record/reports" => "reports#get_reports", as: :event_record_reports
  get "/record/:event_id" => "reports#inspect_report"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
