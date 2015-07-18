class Video < ActiveRecord::Base
  has_attached_file :video
  validates :title, presence: true
end
