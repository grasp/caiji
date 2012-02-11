# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'pathname'
require 'mongoid'
require "logger"
require 'Win32Api'  

pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")
require File.join(project_root,"app","models","mphone.rb")
require File.join(project_root,"app","models","lib_phone.rb")
require File.join(project_root,"app","helpers","cities_helper.rb")


Mongoid.database = Mongo::Connection.new('localhost', 27017).db('grasp_development') #first set as grasp

puts  "total phone=#{LibPhone.count}"
puts  "not sent phone=#{LibPhone.where(:sent_counter=>nil).count}"
puts  "sented  1 phone=#{LibPhone.where(:sent_counter=>1).count}"
puts  "sented  2 phone=#{LibPhone.where(:sent_counter=>2).count}"

not_sent_array=Array.new
sent_one_array=Array.new
notsent=File.new("./notsent.txt", "w+")
sentone=File.new("./sentone.txt", "w+")
LibPhone.where(:sent_counter=>nil).each do |libphone|
  notsent<<libphone.mphone+"\n"
end
LibPhone.where(:sent_counter=>1).each do |libphone|
 sentone<<libphone.mphone+"\n"
end
if false
Mongoid.database = Mongo::Connection.new('localhost', 27017).db('caiji_development') #first set as grasp

 not_sent_array.each do |libphone|
  if libphone.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Mphone.where(:mphone=>libphone).count==0
    Mphone.create(:mphone=>libphone,:operator=>get_operator(libphone)) 
    puts "update #{libphone}"
    end
  end
end

sent_one_array.each do |libphone|
  if libphone.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Mphone.where(:mphone=>libphone).count==0
     Mphone.create(:mphone=>libphone,:operator=>get_operator(libphone),:scount=>1) 
    puts "update #{libphone}"
    end
  end
end

puts  "mphone total phone=#{Mphone.count}"
puts  "mphone not sent phone=#{Mphone.where(:sent_counter=>nil).count}"
puts  "mphone sented  1 phone=#{Mphone.where(:sent_counter=>1).count}"
puts  "mphone sented  2 phone=#{Mphone.where(:sent_counter=>2).count}"
end