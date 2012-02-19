#coding:gb2312
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'pathname'
require 'mongoid'
require "logger"
#require 'Win32Api'  
require 'active_support'

pn = Pathname.new(File.dirname(__FILE__))
$project_root=pn.parent.parent.parent #do we have one line solution?
require File.join($project_root,"app","models","mphone.rb")
require File.join($project_root,"app","helpers","cities_helper.rb")


#$mongo=Mongo::Connection.new('localhost', 27017)
$mongo=Mongo::Connection.new('192.168.2.4', 27017)
Mongoid.database = $mongo.db('caiji_development') 


sent_time=[9,10,11,12,14,15,16,17]
fail_count=0
while true do 
if sent_time.include?(Time.now.hour) 
 daily_count=Mphone.where(:scount=>1,:updated_at.gte=>Time.now.at_beginning_of_day).count
 
puts "daylycount=#{daily_count}"
if daily_count>500
puts "we are done for today"
exit
end
start=Time.now
Mphone.where(:scount=>nil,:operator=>1).limit(1).each do |phone|
begin 
     puts "daily_count=#{daily_count} to #{phone.mphone}"  	  
	 advertise="物流零距离网-http://w090.com上面的货源信息最多,我们愿为您的物流事业助上一臂之力,欢迎您的访问!"	
	 #command="sms.bat"+" "+"15967126712"+" "+advertise
	  command="sms.bat"+" "+phone.mphone+" "+advertise 
	  sendsms_command = Thread.new do
      system(command) # long-long programm
     end	 
	 sendsms_command.join  
	 phone.update_attribute(:scount,1)
	 puts "send one msg time=#{Time.now-start} second!!"
     sleep 40	 
  	 rescue
     puts "Exception in send sms"
      puts $@
	  fail_count+=1
	  exit if fail_count>10 #auto exit if too much fail there
	   sleep 25	
    end
end
else
puts "sleep 300 second"
sleep 300

end
end


puts "we are end of run here"

