class GifsController < ApplicationController
  before_action :set_gif, only: [:validate, :compose, :progress, :show, :queue]

  def index
    @gifs = Gif.all
  end

  def new
    @gif = Gif.new
  end

  def compose
    if @gif.needs_composing? && @gif.succeeded_external_validation?
      render_for_bindings
    else
      redirect_to_correct_flow 
    end
  end

  def create
    @gif = Gif.new(gif_params)
    @gif.session = current_session

    if @gif.save
      redirect_to validate_gif_path(@gif)
    else
      render new_gif_path
    end
  end

  def queue
    if @gif.needs_composing? && @gif.succeeded_external_validation?
      if @gif.update(gif_compose_params)
        @gif.queue_image_for_processing
        redirect_to progress_gif_path(@gif)
      else
        redirect_to new_gif_path, flash: { error: "Something went wrong... Try again later."}
      end
    else
      redirect_to_correct_flow
    end
  end

  def validate
    if @gif.needs_external_validation? || @gif.failed_external_validation?
      render_for_bindings
    else
      redirect_to_correct_flow
    end
  end

  def show
    if @gif.ready?
      render_for_bindings
    else
      redirect_to_correct_flow
    end
  end

  def progress
    if @gif.queued?
      render_for_bindings
    else
      redirect_to_correct_flow
    end
  end

  private

  def render_for_bindings
    respond_to do |format|
      format.html
      format.json { render json: @gif.to_json }
    end
  end

  def redirect_to_correct_flow
    if (@gif.needs_external_validation? || @gif.failed_external_validation?)
      go_to_flow validate_gif_path(@gif)
    elsif (@gif.needs_composing?)
      go_to_flow compose_gif_path(@gif)
    elsif (@gif.ready?)
      go_to_flow gif_path(@gif)
    else
      go_to_flow progress_gif_path(@gif)
    end
  end

  def go_to_flow(redirect_path)
    respond_to do |format|
      format.html { redirect_to redirect_path }
      format.json { render json: { force_refresh: true }}
    end
  end

  def set_gif
    @gif = Gif.find(params[:id])
  end

  def gif_params
    params.require(:gif).permit(:source_url)
  end

  def gif_compose_params
    params.require(:gif).permit(:start_frame, :end_frame)
  end
end
