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



Mongoid.database = Mongo::Connection.new('localhost', 27017).db('caiji_development') #first set as grasp

 File.open("notsent.txt").each do |libphone|
  if libphone.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Mphone.where(:mphone=>libphone.strip).count==0
    Mphone.create(:mphone=>libphone.strip,:operator=>get_operator(libphone.strip)) 
    puts "update #{libphone.strip}"
    else
      
    end
  end
end

File.open("sentone.txt").each do |libphone|
  if libphone.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Mphone.where(:mphone=>libphone.strip).count==0
     Mphone.create(:mphone=>libphone.strip,:operator=>get_operator(libphone.strip),:scount=>1) 
    puts "update #{libphone.strip}"
   end
  end
end

puts  "mphone total phone=#{Mphone.count}"
puts  "mphone not sent phone=#{Mphone.where(:sent_counter=>nil).count}"
puts  "mphone sented  1 phone=#{Mphone.where(:sent_counter=>1).count}"
puts  "mphone sented  2 phone=#{Mphone.where(:sent_counter=>2).count}"
