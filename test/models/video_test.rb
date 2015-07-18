require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test "Video requires presence of title" do
    assert_no_difference("Video") do
      Video.create
    end
  end
end
