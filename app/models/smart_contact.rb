# To change this template, choose Tools | Templates
# and open the template in the editor.

class SmartContact
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
  
  index :created_at
  index :from_site
  index :mphone
  index :QQ
  index :email
  before_create :check_unique
  #validates_uniqueness_of :mphone
  def check_unique
    repeated=0
    # repeated=Contact.where(:mphone=>self.mphone).count 
    repeated=SmartContact.count(conditions: { :mphone=>self.mphone,:QQ=>self.QQ,:email=>self.email,:fixphone=>self.fixphone,:personname=>self.personname,:from_site=>self.from_site})
    logger.info "repeated=#{repeated}"
    puts "repeated=#{repeated}"
    if  repeated > 0
      return false
    end
    return true
  end
end
