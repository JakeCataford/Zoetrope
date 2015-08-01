class ValidateYoutubeLinkJob < ActiveJob::Base
  def perform(gif_id)
    @gif = Gif.find(gif_id)

    begin
      @gif.fetch_title
      @gif.fetch_video_length
      if (@gif.video_download_link.nil?)
        @gif.failed_external_validation!
      else
        @gif.succeeded_external_validation!
      end
    rescue StandardError => e
      @gif.failed_external_validation!
      raise e
    end
  end
end
