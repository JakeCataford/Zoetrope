class ValidateYoutubeLinkJob < ActiveJob::Base
  def perform(gif_id)
    @gif = Gif.find(gif_id)
    @gif.fetch_title

    if (@gif.fetch_video_length > 600)
      @gif.failed_external_validation!
    end

    if (@gif.video_download_link.nil?)
      @gif.failed_external_validation!
    else
      @gif.succeeded_external_validation!
    end
  end
end
