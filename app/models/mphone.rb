class Mphone
   include Mongoid::Document
   include Mongoid::Timestamps
 
  field:mphone,:type=>String
  field :valid,:type=>Boolean
  field :operator,:type=>Integer
  field :scount,:type=>Integer
  index:mphone=>1
  validates_uniqueness_of :mphone
end

