class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_session

  def set_session
    unless session.has_key? :current_session
      s = Session.create!
      session[:current_session] = s.id
    end
  end

  def current_session
    Session.find(session[:current_session])
  end
end
