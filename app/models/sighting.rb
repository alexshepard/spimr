class Sighting < ActiveRecord::Base
  attr_accessible :date, :finder_person_name, :latitude, :location_name, :longitude, :spime_id
  
  acts_as_gmappable :process_geocoding => false
  
  belongs_to    :spime
  
  validates :spime_id, :presence => true
  
  default_scope order("date DESC")
  
  
  #def gmaps4rails_infowindow
  #  "<p style=\"color:black\">#{finder_person_name} found #{spime.name} here at #{self.location_name}</p>"
  #end
    
end
