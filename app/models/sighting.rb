class Sighting < ActiveRecord::Base
  attr_accessible :date, :finder_person_name, :latitude, :location_name, :longitude, :spime_id
  
  belongs_to    :spime
  
  validates :spime_id, :presence => true
  
  default_scope order("date DESC")
  
end
