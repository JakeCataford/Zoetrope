class Gif < ActiveRecord::Base
  YOUTUBE_URL_PATTERN = /(?:https:\/\/|http:\/\/)?(?:www\.)?youtu\.?be(?:\.com)?\/(?:watch\?v=)?([\-_A-Za-z0-9]+)(?:\?)?/i
  YOUTUBE_INFO_URL = "http://youtube.com/get_video_info/%s"
  before_save :set_video_download_link, :set_title, :set_video_length
  before_validation :set_start_time_and_end_time
  belongs_to :session

  enum queue_status: [:needs_composing, :queued, :processing, :ready]
  enum external_validation_status: [:needs_external_validation, :failed_external_validation, :succeeded_external_validation]

  validates :source_url, presence: true
  validate :source_url, :has_properly_formed_source_url?
  validates :video_length, length: {minimum: 1, maximum: 10.minutes.to_seconds}
  validates :start_time, :end_time

  after_create :externally_validate_download_link


  validate :start_time, :end_time, :gif_length?
  def gif_length?
    if (start_time - end_time).abs > 1
      true
    else
      errors.add(:start_time, :end_time, "Gif is too short.")
      false
    end
  end

  validate :start_time, :valid_start_time?
  def valid_start_time?
    if valid_marker?(start_time)
      true
    else
      errors.add(:start_time, "Not a valid start_time marker.")
      false
    end
  end

  validate :end_time, :valid_end_time?
  def valid_end_time?
    if valid_marker?(end_time)
      true
    else
      errors.add(:end_time, "Not a valid end_time marker.")
      false
    end
  end
  def has_properly_formed_source_url?
    if is_youtube_url?(source_url)
      true
    else
      errors.add(:source_url, "Not a valid youtube url.")
      false
    end
  end

  def youtube_video_id
    return nil if source_url.nil? || !is_youtube_url?(source_url)
    source_url.match(YOUTUBE_URL_PATTERN).captures.last
  end

  def set_title
    self.title = youtube_video_info["title"][0]
  end

  def set_video_length
    self.video_length = youtube_video_info["length_seconds"][0].to_i
  end

  validate :source_url, :youtube_link_is_active?
  def youtube_link_is_active?
    if info = youtube_video_info
      info
    else
      errors.add(:source_url, "This youtube video does not exist, or is private.")
      nil
    end
  end

  def youtube_video_info
    return cached_video_info unless cached_video_info.nil?
    conn = Faraday.new(:url => 'http://www.youtube.com')
    info_url = "/get_video_info?video_id=#{youtube_video_id}&el=embedded"
    response = conn.get info_url
    return nil unless response.success?
    info = CGI.parse(response.body)
    puts info
    if info["status"][0] == "ok"
      info
    else
      nil
    end
  end

  def youtube_video_token
    youtube_video_info["token"][0]
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

  def valid_marker?(m)
    if m >= 0 && m <= video_length
      return true
    else
      return false
    end
  end

  def cache_key
    "gifs.#{id}"
  end
end
