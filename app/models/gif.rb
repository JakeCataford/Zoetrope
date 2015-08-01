class Gif < ActiveRecord::Base
  YOUTUBE_URL_PATTERN = /(?:https:\/\/|http:\/\/)?(?:www\.)?youtu\.?be(?:\.com)?\/(?:watch\?v=)?([\-_A-Za-z0-9]+)(?:\?)?/i
  YOUTUBE_INFO_URL = "http://youtube.com/get_video_info/%s"
  belongs_to :session

  enum queue_status: [:needs_composing, :queued, :processing, :ready]
  enum external_validation_status: [:needs_external_validation, :failed_external_validation, :succeeded_external_validation]

  validates :source_url, presence: true
  validates :video_length, length: {minimum: 1, maximum: 600}, unless: 'video_length.nil?'

  before_save :constrain_time_to_video_duration, :reconcile_start_end_times_to_be_sequential, if: Proc.new { !start_time.nil? || !end_time.nil? }

  after_create :externally_validate_download_link


  validate :start_time, :end_time, :gif_is_not_too_short?, if: Proc.new { !start_time.nil? || !end_time.nil? }
  def gif_is_not_too_short?
    if (start_time - end_time).abs > 1
      true
    else
      errors.add(:start_time, :end_time, "Gif is too short.")
      false
    end
  end

  validate :source_url, :has_properly_formed_source_url?
  def has_properly_formed_source_url?
    if is_youtube_url?(source_url)
      true
    else
      errors.add(:source_url, "Not a valid youtube url.")
      false
    end
  end

  def constrain_time_to_video_duration
    self.start_time = clamp(start_time, 0, video_length)
    self.end_time = clamp(end_time, 0, video_length)
  end

  def reconcile_start_and_end_times_to_be_sequential
    self.start_time, self.end_time = [start_time, end_time].sort
  end

  def youtube_video_id
    return nil if source_url.nil? || !is_youtube_url?(source_url)
    source_url.match(YOUTUBE_URL_PATTERN).captures.last
  end

  def fetch_title
    self.title = youtube_video_info["title"][0]
  end

  def fetch_video_length
    self.video_length = youtube_video_info["length_seconds"][0].to_i
  end

  def youtube_video_info
    Rails.cache.fetch("#{cache_key}.video_info", expires_in: 1.minutes) do
      info_url = "http://www.youtube.com/get_video_info?video_id=#{youtube_video_id}&el=embedded"
      response = Faraday.get info_url

      return nil unless response.success?

      info = CGI.parse(response.body)

      if info["status"][0] == "ok"
        info
      else
        nil
      end
    end
  end

  def video_download_link
    attempts = 0
    begin
      Rails.cache.fetch("#{cache_key}.video_download_link", expires_in: 1.minutes) do
        urls = ViddlRb.get_urls(source_url)
        unless urls.nil?
          urls.first
        end
      end
    rescue ViddlRb::DownloadError
      attempts += 1
      retry if attempts < 3
      nil
    end
  end

  def is_youtube_url?(s)
    s =~ YOUTUBE_URL_PATTERN
  end

  def externally_validate_download_link
    ValidateYoutubeLinkJob.new(id).enqueue if self.needs_external_validation?
  end

  def queue_image_for_processing
    ProcessVideoToGifJob.new(id, self.video_download_link).enqueue
    self.status = "Image is queued for processing."
    queued!
  end

  def cache_key
    "gifs.#{id}"
  end

  private

  def clamp(value, low, high)
    [low, value, high].sort[1]
  end
end
