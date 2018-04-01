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
    if params[:ratings]
      @ratings = params[:ratings].keys
      session[:rating_filter] = @ratings
    else
      if !session[:rating_filter].blank?
        @ratings = session[:rating_filter]
        query = {}
        @ratings.each do |rating|
          query["ratings[#{rating}]"] = 1
        end
        query[:order_by]=params[:order_by] ? params[:order_by] : session[:movie_order]
        redirect_to movies_path(query)
      else
        @ratings = Movie.get_ratings
        session[:rating_filter] = @ratings
      end
    end
    
    
    @movies = Movie.all.where(rating: @ratings)
    
    if params[:order_by]
      @order_by = params[:order_by]
      session[:movie_order] = @order_by
    elsif session[:movie_order]
      @order_by = session[:movie_order]
    else
      @order_by = "default"
    end
    
    if @order_by == "title"
      @movies = @movies.order @order_by
      @title_class = "hilite"
    elsif @order_by == "release_date"
      @movies = @movies.order release_date: :desc
      @date_class = "hilite"
    end
      
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
