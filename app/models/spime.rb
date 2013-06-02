class Spime < ActiveRecord::Base
  attr_accessible :date_manufactured, :description, :image, :materials, :name, :public
  
  has_many :sightings, :dependent => :destroy
  
  validates :name,                :presence => true
  validates :description,         :presence => true
  validates :image,               :presence => true
  validates :materials,           :presence => true
  validates :date_manufactured,   :presence => true
  
  validates :image, :format => {
    :with     => %r{\.(gif|jpg|png)$}i,
    :message => 'must be a URL for GIF, JPG, or PNG image.'
  }
  
  scope :uuid, lambda {|uuid| where(:uuid => uuid) } 
  
  before_save :generate_uuid
  
  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

end
