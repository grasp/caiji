#coding:utf-8
require 'rubygems'
require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

if false
Cargo.where(:from_site=>"56qq",:posted.ne=>"yes").each do |cargo|
  timetag=cargo.timetag
  timetag_revocer=timetag.to_s.gsub(":","-")
  cargo.update_attribute(:timetag,timetag_revocer)
  puts "recover #{timetag} to timetag_revocer =#{cargo.timetag}"
end

end