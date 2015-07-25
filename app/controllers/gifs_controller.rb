class GifsController < ApplicationController
  def index
    @gifs = Gif.all
  end

  def new
    @gif = Gif.new
  end

  def create
    gif = Gif.new(gif_params)
    gif.session = current_session

    if gif.save
      redirect_to gif_path(gif)
    else
      redirect_to :back
    end
  end


  private

  def gif_params
    params.require(:gif).permit(:source_url)
  end

end
