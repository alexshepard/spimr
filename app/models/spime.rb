class Spime < ActiveRecord::Base
  attr_accessible :date_manufactured, :description, :image, :materials, :name, :public
  
  validates :name,                :presence => true
  validates :description,         :presence => true
  validates :image,               :presence => true
  validates :materials,           :presence => true
  validates :date_manufactured,   :presence => true
  
  validates :image, :format => {
    :with     => %r{\.(gif|jpg|png)$}i,
    :message => 'must be a URL for GIF, JPG, or PNG image.'
  }

end
