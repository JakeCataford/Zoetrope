require 'open4'

class FFMpegVideoGifConverter
  PROGRESS_MATCHER = /frame=(.*?),/i

  def initialize(file_path, options = {})
    @file_path = file_path

    defaults = {
      start_frame: 0,
      length: 100,
      flags: "lanczos",
      fps: 21,
      scale: 0.5
    }

    @options = defaults.merge(options)
  end

  def create_optimization_pallete!(&on_progress)
    command = "ffmpeg -y "
    command << "-i #{@file_path} "
    command << "-lavfi "
    command << "\""
    command << "trim=start_frame=#{@options[:start_frame]}:end_frame=#{@options[:start_frame] + @options[:length]},"
    command << "fps=#{@options[:fps]},"
    command << "scale=iw*#{@options[:scale]}:ih*#{@options[:scale]}"
    command << ":flags=#{@options[:flags]},palettegen "
    command << "\" "
    command << pallete_output_path

    command.chomp!

    success = exec_ffmpeg_command(command) do |progress|
      on_progress.call progress
    end

    raise "Failed to create ffmpeg optimization pallete" unless success

    @optimization_pallete = pallete_output_path
  end

  def transcode(&on_progress)
    puts "WARNING: you are creating a gif without first creating a palette, call 'create_optimization_pallete!' before `transcode` for higher quality output." if @optimization_pallete.nil?

    command = "ffmpeg "
    command << "-i #{@file_path} "
    command << "-i #{@optimization_pallete} " unless @optimization_pallete.nil?
    command << "-lavfi "
    command << "\""
    command << "trim=start_frame=#{@options[:start_frame]}:end_frame=#{@options[:start_frame] + @options[:length]},"
    command << "fps=#{@options[:fps]},"
    command << "scale=iw*#{@options[:scale]}:ih*#{@options[:scale]}:"
    command << "flags=#{@options[:flags]},"
    command << "paletteuse=dither=sierra2" unless @optimization_pallete.nil?
    command << "\" "
    command << "-y "
    command << output_path

    command.chomp!

    success = exec_ffmpeg_command(command) do |progress|
      on_progress.call progress
    end

    raise "Failed to transcode video to gif." unless success

    output_path
  end

  def output_path
    "#{@file_path}.gif"
  end

  def pallete_output_path
    "#{@file_path}.pallete.png"
  end

  private

  def exec_ffmpeg_command(command, &on_progress)
    status = Open4.popen4(command) do |pid, stdin, stdout, stderr|
      stdin.close
      stderr.each_line do |line|
        puts line
        frame_number = get_frame_number_from_output(line)
        on_progress.call frame_number.to_i unless frame_number.nil?
      end

      stdout.each_line do |line|
        puts line
      end
    end

    return status.success?
  end

  def get_frame_number_from_output(line)
    match = line.match(/frame= ([0-9]*)/)
    match.captures.first.strip unless match.nil?
  end
end
