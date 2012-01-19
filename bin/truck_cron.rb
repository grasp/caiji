#coding:utf-8

require "./cron_init.rb"

class CronTruck
  include TruckRulesHelper
  include CitiesHelper
  include CaijiHelper
  
  def truck_cron(sitename,rulename)
    cron_run_truck_rule(sitename,rulename)
  end
end


start=Time.now

CronTruck.new.truck_cron("tf56","tf56truck")
puts "cost time=#{Time.now-start}"




