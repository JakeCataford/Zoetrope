class ValidateYoutubeLinkJob < ActiveJob::Base
  def perform(gif_id)
    @gif = Gif.find(gif_id)

    begin
      @gif.title = @gif.youtube_video_title(@gif.source_url)
      @gif.video_length = @gif.youtube_video_length(@gif.source_url)
      if (@gif.youtube_video_download_link(@gif.source_url).nil?)
        @gif.abort("We couldn't find that video, maybe the url is wrong or the video is protected via DRM?")
      else
        @gif.validated!
      end
    rescue YoutubeVideo::VideoLinkUnavailable,
           YoutubeVideo::VideoMetadataUnavailable,
           StandardError => e
      @gif.abort("We couldn't validate your video. Maybe it's protected by DRM or the url is wrong.")
      raise e
    end
  end
end
