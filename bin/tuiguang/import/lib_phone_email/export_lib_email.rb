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
require File.join(project_root,"app","models","lib_email.rb")
require File.join(project_root,"app","helpers","cities_helper.rb")


Mongoid.database = Mongo::Connection.new('localhost', 27017).db('grasp_development') #first set as grasp

puts  "total phone=#{LibEmail.count}"
puts  "not sent phone=#{LibEmail.where(:sent_counter=>nil).count}"
puts  "sented  1 phone=#{LibEmail.where(:sent_counter=>1).count}"
puts  "sented  2 phone=#{LibEmail.where(:sent_counter=>2).count}"

not_sent_array=Array.new
sent_one_array=Array.new
notsent=File.new("./notsentemail.txt", "w+")
sentone=File.new("./sentoneemail.txt", "w+")
LibEmail.where(:sent_counter=>nil).each do |libemail|
  notsent<<libemail.Email+"\n"
end
LibEmail.where(:sent_counter=>1).each do |libemail|
 sentone<<libemail.Email+"\n"
end
if false
Mongoid.database = Mongo::Connection.new('localhost', 27017).db('caiji_development') #first set as grasp

 not_sent_array.each do |libemail|
  if libemail.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Email.where(:address>libemail).count==0
    Email.create(:address>libemail) 
    puts "update #{libemail}"
    end
  end
end

sent_one_array.each do |libemail|
  if libemail.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Email.where(:address>libemail).count==0
     Email.create(:address>libemail,:scount=>1) 
        puts "update #{libemail}"
    end
  end
end

puts  "Email total phone=#{Email.count}"
puts  "Email not sent phone=#{Email.where(:sent_counter=>nil).count}"
puts  "Email sented  1 phone=#{Email.where(:sent_counter=>1).count}"
puts  "Email sented  2 phone=#{Email.where(:sent_counter=>2).count}"
end