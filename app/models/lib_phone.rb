class LibPhone
  include Mongoid::Document
  include Mongoid::Timestamps
  field :mphone, :type => String
  field :qq, :type => String
  field :fixphone, :type => String
  field :role, :type => String
  
  #statistic
  field :last_sent_time,:type=>String
  field :sent_counter,:type=>Integer
  field :status,:type=>String  
  #index ({mphone: 1} , {unique: true})
  index({ mphone: 1 }, { unique: true })
  index :created_at=>1
   validates_uniqueness_of :mphone ,:message=>"mobile phone exisit"
end
