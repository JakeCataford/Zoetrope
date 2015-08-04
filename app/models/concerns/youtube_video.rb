require 'active_support/concern'
require 'digest/md5'

module YoutubeVideo
  extend ActiveSupport::Concern

  YOUTUBE_URL_PATTERN = /(?:https:\/\/|http:\/\/)?(?:www\.)?youtu\.?be(?:\.com)?\/(?:watch\?v=)?([\-_A-Za-z0-9]+)(?:\?)?/i
  YOUTUBE_INFO_URL = "http://youtube.com/get_video_info/%s"

  class VideoLinkUnavailable < StandardError; end
  class VideoMetadataUnavailable < StandardError; end

  included do
    def youtube_video_title
      metadata = youtube_video_metadata
      metadata["title"][0] unless metadata.nil?
    end

    def youtube_video_length
      metadata = youtube_video_metadata
      metadata["length_seconds"][0].to_i unless metadata.nil?
    end

    def youtube_video_id
      return nil if source_url.nil? || !is_youtube_url?(source_url)
      source_url.match(YOUTUBE_URL_PATTERN).captures.last
    end

    def youtube_video_metadata
      Rails.cache.fetch("#{video_cache_key}.video_metadata", expires_in: 1.minutes) do
        metadata_url = "http://www.youtube.com/get_video_info?video_id=#{youtube_video_id}&el=embedded"
        response = Faraday.get metadata_url

        if response.success?
          metadata = CGI.parse(response.body)
          if metadata["status"][0] == "ok"
            return metadata
          end
        end

        raise VideoMetadataUnavailable.new
      end
    end


    def youtube_video_download_link
      attempts = 0
      begin
        Rails.cache.fetch("#{video_cache_key}.video_download_link", expires_in: 1.minutes) do
          urls = ViddlRb.get_urls(source_url)
          unless urls.nil?
            urls.first
          end
        end
      rescue ViddlRb::DownloadError
        attempts += 1
        retry if attempts < 3
        raise VideoLinkUnavailable.new
      end
    end

    def video_cache_key
      Digest::MD5.hexdigest(source_url)
    end

    def is_youtube_url?(s)
      s =~ YOUTUBE_URL_PATTERN
    end
  end
end
