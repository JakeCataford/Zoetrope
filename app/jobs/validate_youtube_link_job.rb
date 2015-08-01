class ValidateYoutubeLinkJob < ActiveJob::Base
  def perform(gif_id)
    @gif = Gif.find(gif_id)
    if (@gif.video_download_link.nil?)
      @gif.failed_external_validation!
    else
      @gif.succeeded_external_validation!
    end
  end
end
