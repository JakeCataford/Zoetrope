require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test "Video requires presence of title" do
    assert_no_difference("Video.count") do
      Video.create
    end
  end

  test "Video requires a description" do
    assert_no_difference("Video.count") do
      Video.create
    end
  end
end
