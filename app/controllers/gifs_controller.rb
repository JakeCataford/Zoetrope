class GifsController < ApplicationController
  def index
    @gifs = Gif.all
  end

  def new
    @gif = Gif.new
  end

  def create
    @gif = Gif.new(gif_params)
    @gif.session = current_session

    if @gif.save
      @gif.queue_image_for_processing
      redirect_to progress_gif_path(@gif)
    else
      render new_gif_path
    end
  end

  def show
    @gif = Gif.find(params[:id])

    if @gif.ready?
      respond_to do |format|
        format.html
        format.json { render json: @gif.to_json }
      end
    else
      redirect_to progress_gif_path(@gif) unless @gif.ready?
    end
  end

  def progress
    @gif = Gif.find(params[:id])

    if @gif.ready?
      respond_to do |format|
        format.html do
          redirect_to gif_path(@gif)
        end

        format.json do
          render json: { force_refresh: true }
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: @gif.to_json }
      end
    end
  end

  private

  def gif_params
    params.require(:gif).permit(:source_url)
  end
end
