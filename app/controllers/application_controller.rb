class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from StandardError do |e|
    render json: { error: e.message, backtrace: e.backtrace.first(5) }, status: :internal_server_error
  end
end
