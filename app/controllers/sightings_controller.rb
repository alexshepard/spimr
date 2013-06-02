class SightingsController < ApplicationController

  respond_to :html
    
  def create
    @sighting = spime.sightings.new(params[:sighting])
    @sighting.date = Time.now

    new_was_successful = @sighting.save
    
    respond_with [spime, @sighting] do |format|
      format.html {
        if new_was_successful
          redirect_to(spime_path(spime), :notice => 'The sighting was created.')
        else
          render 'new'
        end
      }
    end
  end
  
  def edit
    @sighting = spime.sightings.find(params[:id])
    
    respond_with [spime, @sighting]
  end
  
  def update
    @sighting = spime.sightings.find(params[:id])
    update_was_successful = @sighting.update_attributes(params[:id])
    
    respond_with [spime, @sighting] do |format|
      format.html {
        if update_was_successful
          redirect_to(spime_path(spime), :notice => 'The sighting was updated')
        else
          render 'edit'
        end
      }
    end
  end
  
  def destroy
    sighting = spime.sightings.find(params[:id])
    if (sighting.destroy)
      flash[:notice] = 'The sighting was destroyed.'
    else
      flash[:alert] = 'The sighting could not be destroyed.'
    end
    
    respond_with [spime, sighting] do |format|
      format.html {
        redirect_to(spime_path(spime))
      }
    end
  end

  private
  
  def spime
    @spime ||= Spime.find(params[:spime_id])
  end

end