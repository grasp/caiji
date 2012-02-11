#coding:gb2312
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'pathname'
require 'mongoid'
require "logger"
require 'Win32Api'  

pn = Pathname.new(File.dirname(__FILE__))
$project_root=pn.parent.parent #do we have one line solution?
require File.join($project_root,"app","models","mphone.rb")
require File.join($project_root,"app","helpers","cities_helper.rb")


$mongo=Mongo::Connection.new('localhost', 27017)
Mongoid.database = $mongo.db('caiji_development') 



MPhone.where(:scount=>nil,:operator=>1).each do |phone|
begin 
 if LibPhone.where(:sent_counter=>1).count>3200
 break;
 end
  puts " sending to #{phone.mphone} ,count1=#{MPhone.where(:scount=>1).count}, count0=#{MPhone.where(:scount=>nil).count}"
  
	  
	 advertise="物流零距离网-http://w090.com免费提供大量的货源和车源信息以及货源信息订阅,为您的物流助上一臂之力,欢迎您的访问!"
	
	 #  command="sms.bat"+" "+"15967126712"+" "+advertise
	 command="sms.bat"+" "+"15394238771"+" "+advertise
	# command="sms.bat"+" "+phone.mphone+" "+advertise
	  sendsms_command = Thread.new do
      system(command) # long-long programm
       sendsms_command.join  		  
       phone.inc(:scount,1)	 
    end
	 sleep 25
  end

rescue
puts "Exception in send sms"
puts $@
end
end

