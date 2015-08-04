class Gif < ActiveRecord::Base
  include YoutubeVideo

  belongs_to :session

  enum queue_status: [:validating, :composing, :queued, :processing, :ready, :aborted]

  validates :source_url, presence: true
  validates :video_length, length: {minimum: 1, maximum: 600}, unless: "video_length.nil?"
  validates_presence_of :session

  before_save :constrain_time_to_video_duration, :reconcile_start_and_end_times_to_be_sequential, if: Proc.new { !start_time.nil? || !end_time.nil? }
  after_create :externally_validate_download_link

  validate :start_time, :end_time, :gif_is_not_too_short?, if: Proc.new { !start_time.nil? || !end_time.nil? }
  def gif_is_not_too_short?
    if (start_time - end_time).abs > 0.01
      true
    else
      errors.add(:start_time, "Gif is too short.")
      errors.add(:end_time, "Gif is too short.")
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

  def abort(reason)
    self.abort_reason = reason
    aborted!
  end

  def validated!
    composing!
  end

  def constrain_time_to_video_duration
    self.start_time = clamp(start_time, 0, video_length)
    self.end_time = clamp(end_time, 0, video_length)
  end

  def reconcile_start_and_end_times_to_be_sequential
    self.start_time, self.end_time = [start_time, end_time].sort
  end

  def externally_validate_download_link
    validating!
    ValidateYoutubeLinkJob.new(id).enqueue
  end

  def queue_image_for_processing
    ProcessVideoToGifJob.new(id, youtube_video_download_link(source_url)).enqueue
    self.status = "Image is queued for processing."
    queued!
  end

  private

  def clamp(value, low, high)
    [low, value, high].sort[1]
  end
end
