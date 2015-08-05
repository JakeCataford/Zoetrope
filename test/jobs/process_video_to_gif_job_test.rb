require "ffmpeg_video_to_gif_converter"

class ProcessVideoToGifJobTest < ActiveJob::TestCase
  def setup
    VCR.insert_cassette(:jobs, record: :new_episodes)
    FFMpegVideoGifConverter.any_instance.stubs(:create_optimization_pallete!)
    FFMpegVideoGifConverter.any_instance.stubs(:transcode)
    FFMpegVideoGifConverter.any_instance.stubs(:output_path).returns(file_fixture_path("sonic.gif"))
    File.stubs(:delete) # or the fixtures get blown away
    @gif = gifs(:composing)
  end

  def teardown
    VCR.eject_cassette
  end

  test "happy path" do
    ProcessVideoToGifJob.perform_now(@gif.id, @gif.youtube_video_download_link)
    assert(@gif.queue_status, Gif.queue_statuses["ready"])
  end

  test "media transcoding" do
    
  end

  private

  def file_fixture_path(filename)
    "#{Rails.root}/test/fixtures/files/#{filename}"
  end
end
