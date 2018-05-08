class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.get_ratings
    @ratings = params[:ratings] || session[:rating_filter] || {}
    @ratings = (@all_ratings.map {|option| [option,1]}).to_h if @ratings.blank?
    
    sort = params[:order_by] || session[:movie_order] 
    case sort
    when "title"
      @order_by,@title_class = {"title"=>"asc"},"hilite"
    when "release_date"
      @order_by,@title_class = {"release_date"=>"desc"},"hilite"
    end
    
    if @ratings!=session[:rating_filter] || sort!=session[:movie_order]
      # debugger
      session[:rating_filter],session[:movie_order] = @ratings, sort
      redirect_to movies_path(order_by: sort, ratings: @ratings) and return
    end
        
    @movies = Movie.all.where(rating: @ratings.keys).order(@order_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
