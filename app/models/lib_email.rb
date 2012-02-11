class LibEmail
  include Mongoid::Document
    include Mongoid::Timestamps
  field :email, :type => String
  field :qq, :type => String
  field :context, :type => String
  field :url, :type => String
  field :keyword_id, :type => String
  field :from_engine, :type => String
  field :matched,:type=>Integer
  
  field :engine_id
  
   #for mail sent statistic
  field :last_sent_time,:type=>String
  field :sent_counter,:type=>Integer
  field :status,:type=>String  
  field :subscribeyes
  index :email,unique: true
  index :created_at
   validates_uniqueness_of :email ,:message=>"email exisit"
end
