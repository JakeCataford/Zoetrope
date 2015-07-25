require 'test_helper'

class GifTest < ActiveSupport::TestCase
  def setup
    @new_gif = Gif.new
    @gif = gifs(:gif_with_valid_source_url)
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

  test "#youtube_video_id gets video id from long form source_url" do
    video_id = "1a3b5c7f"
    @new_gif.source_url = "http://youtube.com/watch?v=#{video_id}"
    assert_equal(video_id, @new_gif.youtube_video_id)
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

  test "download link is set on save" do
    @gif.save
    assert(@gif.video_download_link, "Download link did not get set on save.")
  end

  test "process_image mutates state" do
    assert_state(@gif, :incomplete)
    @gif.process_image!
    assert_state(@gif, :processing)
  end

  test "upload_image mutates state" do
    assert_state(@gif, :processing)
    @gif.upload_image!
    assert_state(@gif, :uploading)
  end

  test "complete mutates state" do
    assert_state(@gif, :processing)
    @gif.complete!
    assert_state(@gif, :ready)
  end

  private
  def assert_state(model, state)
    assert(model.state = state, "State was not as expected. (#{model.state.to_s} instead of #{state})")
  end
end
