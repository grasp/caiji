class Email
  include Mongoid::Document
  include Mongoid::Timestamps
 
  field :address,:type=>String
  field :domain,:type=>String
  field :valid,:type=>Boolean
  field :scount,:type=>Integer  
  index :address=>1
    validates_presence_of :address  
  validates_uniqueness_of :address


end
