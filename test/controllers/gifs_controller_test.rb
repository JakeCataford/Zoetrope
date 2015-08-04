require 'test_helper'

class GifsControllerTest < ActionController::TestCase
  fixtures :gifs

  def setup
    @gif = gifs(:gif_with_valid_source_url)
    session[:current_session] = sessions(:one).id
  end

  test "#index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gifs)
  end

  test "#new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:gif)
    assert_not assigns(:gif).persisted?
  end

  test "#create" do
    post :create, gif: { source_url: "http://youtube.com/watch?v=5bVCz-NlvX4" }
    assert_response :redirect
  end

  test "#validate" do
    gif = gifs(:validating)
    get :validate, id: gif
    assert_response :success
  end

  test "#validate returns json" do
    gif = gifs(:validating)
    get :validate, id: gif, format: :json
    assert_response :success
  end

  test "redirect to composing works" do
    gif = gifs(:composing)
    get :validate, id: gif
    assert_response :redirect
    assert_redirected_to controller: :composing
  end
end
