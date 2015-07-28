require 'ffmpeg_video_to_gif_converter'

class ProcessVideoToGifJob < ActiveJob::Base
  queue_as :default
  def perform(gif_id, url)
    @gif = Gif.find(gif_id)
    update_gif_status("Fetching video from youtube...")
    video_path = download_video(url)
    update_gif_status("Converting video to gif...")
    gif_path = convert_video_to_gif(video_path)
    update_gif_status("Uploading gif to imgur.")
  end

  def download_video(url)
    puts "downloading video\n"
    uri = URI(url)
    begin
      file = Tempfile.open(["gif_#{@gif.id}", ".flv"], Rails.root.join('tmp'), encoding: 'ascii-8bit')
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new uri
        http.request request do |response|
          file_size = response['content-length'].to_i
          amount_downloaded = 0

          response.read_body do |chunk|
            file.write chunk
            amount_downloaded += chunk.size
            percent_downloaded = (amount_downloaded.to_f / file_size * 100)
            update_gif_progress(percent_downloaded)
            print "%.2f%" % percent_downloaded
            print "\r"
          end
        end
      end
    ensure
      file.close
    end
    file.path
  end

  def convert_video_to_gif(video_path)
    vid_to_gif = FFMpegVideoGifConverter.new video_path

    puts "Generating pallete for gif..."
    vid_to_gif.create_optimization_pallete! do |progress|
      puts progress
    end

    puts "Converting video to gif..."
    vid_to_gif.transcode do |progress|
      puts progress
    end

    vid_to_gif.output_path
  end

  def update_gif_status(status)
    @gif.status = status
    raise "Failed to update gif status." unless @gif.save
  end

  def update_gif_progress(progress)
    @gif.progress = progress
    raise "Failed to update gif progress." unless @gif.save
  end
end
