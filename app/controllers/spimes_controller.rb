class SpimesController < ApplicationController
  
  respond_to :html
  
  def checkin
    @spime = Spime.uuidpg(params[:uuid]).first
    
    if @spime
      @sighting = @spime.sightings.new
      respond_with [@spime, @sighting] do |format|
        format.html {
          render 'checkin'
        }
      end
    else
      redirect_to(spimes_path(), :alert => "Invalid checkin attempt.")
    end
      
  end
    
  def index
    @spimes = Spime.all
    
    respond_with @spimes
  end
  
  def show
    @spime = Spime.find(params[:id])
    
    respond_with @spime
  end
  
  def show_qrcode
    @spime = Spime.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(spime_path(@spime)) }
      format.svg { render :qrcode => url_for(:controller => 'spimes', :action => 'checkin', :uuid => @spime.uuid) }
      format.png { render :qrcode => url_for(:controller => 'spimes', :action => 'checkin', :uuid => @spime.uuid) }
      format.jpeg { render :qrcode => url_for(:controller => 'spimes', :action => 'checkin', :uuid => @spime.uuid) }

    end
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