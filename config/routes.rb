require "sidekiq/web"

Rails.application.routes.draw do
  get "/" => redirect("/docs")

  # Open API documentation
  mount OasRails::Engine => "/docs"

  # App Endpoints
  get "/test/:id" => "reports#demo_event_service", as: :test
  get "/demo-create-report" => "reports#demo_create_report", as: :demo_create_report
  post "/events/:event_id/reports" => "reports#create", as: :event_reports
  # get "/events/:event_id/reports/get_history" => "reports#get_history", as: :event_reports_history
  put "/events/:event_id/reports/schedule" => "reports#schedule", as: :event_reports_schedule
  get "/reports/logs" => "reports#get_logs", as: :event_reports_logs
  get "/reports/history" => "reports#get_reports", as: :event_record_reports
  get "/reports/:report_id/user/:user_id" => "reports#inspect_report"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount Sidekiq::Web => "/sidekiq" # mount Sidekiq::Web in your Rails app

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
