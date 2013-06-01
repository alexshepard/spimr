class SpimesController < ApplicationController
  
  respond_to :html
  
  def index
    @spimes = Spime.all
    
    respond_with @spimes
  end
  
  def show
    @spime = Spime.find(params[:id])
    
    respond_with @spime
  end
  
  def new
    @spime = Spime.new
    
    respond_with @spime
  end
  
  def edit
    @spime = Spime.find(params[:id])
  end
  
  def update
    @spime = Spime.find(params[:id])
    update_was_successful = @spime.update_attributes(params[:spime])
    
    respond_with [@spime] do |format|
      format.html {
        if update_was_successful
          redirect_to(spime_path(@spime), :notice => "Spime was updated.")
        else
          render 'edit'
        end
      }
    end
  end
  
  def create
    @spime = Spime.new(params[:spime])
    new_was_successful = @spime.save
    
    respond_with [@spime] do |format|
      format.html {
        if new_was_successful
          redirect_to(spime_path(@spime), :notice => "Spime was created.")
        else
          render 'new'
        end
      }
    end
  end
  
  def destroy
    spime = Spime.find(params[:id])

    if (spime.destroy)
      flash[:notice] = 'The spime was destroyed.'
    else
      flash[:alert] = 'The spime cound not be destroyed.'
    end
    
    respond_with [spime] do |format|
      format.html {
        redirect_to spimes_url
      }
    end
  end

end