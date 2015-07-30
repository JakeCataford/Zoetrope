require 'test_helper'

class GifTest < ActiveSupport::TestCase
  def setup
    VCR.insert_cassette("gif_requests", :record => :new_episodes)
    @new_gif = Gif.new
    @gif = gifs(:gif_with_valid_source_url)
    @gif_shortform
  end

  def teardown
    VCR.eject_cassette
  end

  test "validates source_url presence" do
    @new_gif.save
    assert_errors(@new_gif, :source_url)
  end

  test "validates youtube source_url" do
    @new_gif.source_url = "http://google.com"
    @new_gif.save
    assert_errors(@new_gif, :source_url)
  end

  test "validates long form youtube source_url" do
    assert(@new_gif.is_youtube_url?("http://youtube.com/watch?v=123abc"), "Failed to recognize long form http youtube url.")
    assert(@new_gif.is_youtube_url?("https://youtube.com/watch?v=12a3456"), "Failed to recognize long form https youtube url")
  end

  test "validates short form url" do
    assert(@new_gif.is_youtube_url?("youtu.be/1ewwe23432"), "Failed to recognize short form http youtube url.")
    assert(@new_gif.is_youtube_url?("https://youtu.be/sfjosaf"), "Failed to recognize short form http youtube url.")
  end

  test "viddlerb can get longform url" do
    assert_not_nil(@gif.video_download_link)
  end

  test "#youtube_video_id gets video id from short form source_url" do
    video_id = "1a3b5c7f"
    @new_gif.source_url = "http://youtube.com/watch?v=#{video_id}"
    assert_equal(video_id, @new_gif.youtube_video_id)
  end

  test "validates source_url rejects dead links" do
    @new_gif.source_url = "http://youtube.com/watch?v=SUPERDUPERDEADLINK"
    @new_gif.save
    assert_errors(@new_gif, :source_url)
  end

  test "validates source_url accepts working links" do
    @gif.save
    assert_no_errors(@gif, :source_url)
  end

  test "video_download_link returns a url" do
    assert(@gif.video_download_link, "Download link did not get set on save.")
  end

  test "queue_image mutates state" do
    @gif.state = "incomplete"
    @gif.queue_image!
    assert_state(@gif, "queued")
  end

  test "process_image mutates state" do
    @gif.state = "queued"
    @gif.process_image!
    assert_state(@gif, "processing")
  end

  test "complete mutates state" do
    @gif.state = "processing"
    @gif.complete!
    assert_state(@gif, "ready")
  end

  test "title is set on save" do
    @gif.save
    assert_equal("SVBLM Presents: The Stranger (Release Trailer)", @gif.title)
  end

  private
  def assert_state(model, state)
    assert(model.state == state, "State was not as expected. (#{model.state.to_s} instead of #{state})")
  end
end
