require 'test_helper'

class GifsControllerTest < ActionController::TestCase
  fixtures :gifs

  def setup
    VCR.insert_cassette("gif_requests", :record => :new_episodes)
    @gif = gifs(:gif_with_valid_source_url)
    session[:current_session] = sessions(:one).id
  end

  def teardown
    VCR.eject_cassette
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

  test "#compose" do
    gif = gifs(:composing)
    get :compose, id: gif
    assert_response :success
  end

  test "#compose returns json" do
    gif = gifs(:composing)
    get :compose, id: gif, format: :json
    assert_response :success
  end

  test "queued gifs show progress view" do
    gif = gifs(:queued)
    get :progress, id: gif
    assert_response :success
  end

  test "#queued gifs show progress view" do
    gif = gifs(:queued)
    get :validate, id: gif, format: :json
    assert_response :success
  end

  test "#progress" do
    gif = gifs(:processing)
    get :progress, id: gif
    assert_response :success
  end

  test "#progress returns json" do
    gif = gifs(:processing)
    get :progress, id: gif, format: :json
    assert_response :success
  end


  test "redirect for composing" do
    gif = gifs(:composing)
    get :validate, id: gif
    assert_response :redirect
    assert_redirected_to compose_gif_url(gif)
  end

  test "redirect for queued" do
    gif = gifs(:queued)
    get :validate, id: gif
    assert_response :redirect
    assert_redirected_to progress_gif_url(gif)
  end

  test "redirect for processing" do
    gif = gifs(:processing)
    get :validate, id: gif
    assert_response :redirect
    assert_redirected_to progress_gif_url(gif)
  end

  test "redirect for ready" do
    gif = gifs(:ready)
    get :validate, id: gif
    assert_response :redirect
    assert_redirected_to gif_url(gif)
  end

  test "json force_refresh on redirect" do
    gif = gifs(:ready)
    get :validate, id: gif, format: :json
    assert_response :success
    response_json = JSON.parse(@response.body)
    assert response_json["force_refresh"]
  end
end
