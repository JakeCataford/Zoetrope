class Gif < ActiveRecord::Base
  YOUTUBE_URL_PATTERN = /(?:https:\/\/|http:\/\/)?(?:www\.)?youtu\.?be(?:\.com)?\/(?:watch\?v=)?([A-Za-z0-9]+)(?:\?)?/i
  YOUTUBE_INFO_URL = "http://youtube.com/get_video_info/%s"

  belongs_to :session
  validates :source_url, presence: true

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



  def is_youtube_url?(s)
    s =~ YOUTUBE_URL_PATTERN
  end

  def cache_key
    "gif[#{ id }+#{source_url}]"
  end
end
