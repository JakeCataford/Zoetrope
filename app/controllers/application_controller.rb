class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_session

  def set_session
    session[:session] = Session.new unless session.has_key? :session
  end
end
