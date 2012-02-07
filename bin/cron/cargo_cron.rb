#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron_init.rb")


class CronCargo
  include CargoRulesHelper
  include CargosHelper
  include CitiesHelper
#  include Qq56Helper
  
  def cargo_cron(sitename,rulename)
    cron_run_cargo_rule(sitename,rulename)
  end
end


Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
    every 5.minutes do
    hour=Time.now.hour
    if hour>5 and hour<22
      begin
       CronCargo.new.cargo_cron("tf56","tf56cargo")
       CronCargo.new.cargo_cron("56qq","56qqcargo")
       CronCargo.new.cargo_cron("56135","56135cargo")
      rescue
        puts $@
      end  
      system("wget --spider http://w090.com/admin/dev_expire") #to expire city navi bar
      system("wget --spider http://w090.com/cargos/allcity") #to regenerate city navi  cache
      system("wget --spider http://w090.com/trucks/allcity") #to regenerate city navi  cache
    end
  end
  
   every 10.minutes do
    hour=Time.now.hour
    if hour>6 and hour<22
      begin
       CronCargo.new.cargo_cron("quzhou","quzhoucargo")
       CronCargo.new.cargo_cron("haoyun56","haoyuncargo")
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



