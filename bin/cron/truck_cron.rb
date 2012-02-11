#coding:utf-8

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

class CronTruck
  include TruckRulesHelper
  include CitiesHelper
  include CaijiHelper
  
  def truck_cron(sitename,rulename)
    cron_run_truck_rule(sitename,rulename)
  end
end

Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
    every 5.minutes do
    hour=Time.now.hour
    if hour>5 and hour<22
      begin
       CronTruck.new.truck_cron("tf56","tf56truck")
      rescue
        puts $@
      end  
      system("wget --spider http://w090.com/trucks/allcity") #to regenerate city navi  cache
    end
  end
  
   every 10.minutes do
    hour=Time.now.hour
    if hour>6 and hour<22
      begin
       CronCargo.new.cargo_cron("56qq","56qqtruck")
       rescue
        puts $@
      end  
 
    end
  end
  
    on_error do |e|
    puts "Boom raised: #{e.message} #{Time.now}"
  end

  on_exit do
    puts "Bye bye on #{Time.now}"
  end
end




