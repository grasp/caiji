# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'pathname'
require 'mongoid'
require "logger"
require 'Win32Api'  

pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")
require File.join(project_root,"app","models","Email.rb")
require File.join(project_root,"app","models","lib_phone.rb")
require File.join(project_root,"app","helpers","cities_helper.rb")



Mongoid.database = Mongo::Connection.new('localhost', 27017).db('caiji_development') #first set as grasp

 File.open("notsentemail.txt").each do |libemail|
  unless libemail.nil?
      email=Email.where(:email=>libemail.strip).first
    if email.nil?
    Email.create(:email=>libemail.strip) 
    puts "update #{libemail.strip}"
    end
  end
end

File.open("sentoneemail.txt").each do |libemail|
  unless libemail.nil?
    email=Email.where(:email=>libemail.strip).first
    if email.nil?
     Email.create(:email=>libemail.strip) 
    puts "update #{libemail.strip}"
    else
      email.update_attribute(:scount,1)
   end
  end
end

puts  "Email total phone=#{Email.count}"
puts  "Email not sent phone=#{Email.where(:sent_counter=>nil).count}"
puts  "Email sented  1 phone=#{Email.where(:sent_counter=>1).count}"
puts  "Email sented  2 phone=#{Email.where(:sent_counter=>2).count}"
