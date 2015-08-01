class Gif < ActiveRecord::Base
  YOUTUBE_URL_PATTERN = /(?:https:\/\/|http:\/\/)?(?:www\.)?youtu\.?be(?:\.com)?\/(?:watch\?v=)?([A-Za-z0-9]+)(?:\?)?/i
  YOUTUBE_INFO_URL = "http://youtube.com/get_video_info/%s"
  before_save :set_video_download_link, :set_title, :set_video_length
  before_validation :set_start_time_and_end_time
  belongs_to :session
  validates :source_url, presence: true
  #validates :video_length, length: {minimum: 1, maximum: 36000}
  #validates :start_time, :end_time, if: :gif_length?

  #def valid_marker?(m) 
   # if m >= 0 && m <= video_length
    #  return true
   # else
    #  return false
  #end

  #validate :start_time, :end_time, :gif_length?
  #def gif_length?
    #if (start_time - end_time).abs > 1
      #return true
    #else
      #errors.add(:start_time, :end_time, "Gif is too short.")
      #return false
  #end

  #validate :start_time, :valid_start_time?
  #def valid_start_time?
    #if valid_marker?(start_time)
      #true
    #else
      #errors.add(:start_time, "Not a valid start_time marker.")
      #false
  #end

  #validate :end_time, :valid_end_time?
  #def valid_end_time?
    #if valid_marker?(end_time)
     # true
    #else
    #  errors.add(:end_time, "Not a valid end_time marker.")
   #   false
  #end

  state_machine :state, initial: :incomplete do
    state :queued
    state :processing
    state :uploading
    state :ready

    event :queue_image! do
      transition :incomplete => :queued, if: :image_is_ready_to_be_queued?
    end

    event :process_image! do
      transition :queued => :processing, if: :image_is_ready_for_processing?
    end

    event :upload_image! do
      transition :processing => :uploading, if: :image_is_ready_for_upload?
    end

    event :complete! do
      transition :uploading => :ready
    end
  end

  attr_accessor :cached_video_info

  validate :source_url, :has_properly_formed_source_url?
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

  def set_video_download_link
    self.video_download_link = "http://youtube.com/get_video?t=#{youtube_video_token}&video_id=#{youtube_video_id}&asv=2" if self.video_download_link.nil?
  end

  def is_youtube_url?(s)
    s =~ YOUTUBE_URL_PATTERN
  end

  def image_is_ready_to_be_queued?
    true
  end

  def image_is_ready_for_processing?
    true
  end

  def image_is_ready_for_upload?
    true
  end
end
