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
  
  #for tuiguang
  field :smssent, :type=>Integer   
  field :mailsent, :type=>Integer 
  field :qqsent, :type=>Integer
  
  index :created_at
  index :from_site
  index :mphone
  index :QQ
  index :email

  end
  
     
