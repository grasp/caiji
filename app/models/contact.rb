# coding: utf-8
class  Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field :mphone, :type=>String
  field :fixphone, :type=>String  
  field :QQ, :type=>String
  field :email, :type=>String
  field :address, :type=>String
  field :intro, :type=>String  
  field :personname, :type=>String
  field :line, :type=>String
  field :from_site, :type=>String
  field :companyname, :type=>String
  field :companytype, :type=>String
  field :companyurl, :type=>String
  field :create_time, :type=>String
  field :registermoney, :type=>String
   field :fax, :type=>String   
  field :others, :type=>String
  field :zipcode, :type=>String
  #for tuiguang
  field :smssent, :type=>Integer   
  field :mailsent, :type=>Integer 
  field :qqsent, :type=>Integer
  field :gen, :type=>Integer#makr it as generated, as gen phone always interuppted
  field :genemail, :type=>Integer#makr it as generated, as gen phone always interuppted
  index({ created_at: 1})

  index :from_site=>1
  index :mphone=>1
  index :QQ=>1
  index :email=>1
 before_create :check_unique
#validates_uniqueness_of :mphone
  def check_unique
    repeated=0
  # repeated=Contact.where(:mphone=>self.mphone).count 
   repeated=Contact.count(conditions: { :mphone=>self.mphone,:QQ=>self.QQ,:email=>self.email,:fixphone=>self.fixphone,:personname=>self.personname,:from_site=>self.from_site})
  logger.info "repeated=#{repeated}"
   puts "repeated=#{repeated}"
  if  repeated > 0
      return false
  end
      return true
  end
  end
  
     
