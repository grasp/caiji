#coding:utf-8
require 'rubygems'
require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent #do we have one line solution?
require File.join(project_root,"bin","cron_init.rb")


class CronExpire

end

def compare_time_expired(created_time)
unless (created_time.blank?)
   current_time=Time.now   
   expired_time=5.hours.since(created_time)
   if(Time.parse(expired_time.to_s) -current_time <=0)
      return true
    else
      return false
    end
else
  return false #keep those illegal ?
end
end
logger=Logger.new("expire.log")
Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
    every 1.minutes do
    hour=Time.now.hour
    cargo_expire=0
    truck_expire=0
    if hour>5 and hour<22
      begin
        Cargo.where(:status=>"????").each do |cargo|
          logger.info "cargo=#{cargo.created_at}"
          if compare_time_expired(cargo.created_at)
            cargo.update_attribute("status","????")
            cargo_expire+=1
          end
        end
        
         Truck.where(:status=>"????").each do |truck|
          if compare_time_expired(truck.created_at)
            truck.update_attribute("status","????")
            truck_expire+=1            
          end
        end
       
      rescue
        puts $@
      end  
    end
    logger.info "cargo_expire=#{cargo_expire},truck_expire=#{truck_expire}"
  end
  

  
    on_error do |e|
    puts "Boom raised: #{e.message} #{Time.now}"
  end

  on_exit do
    puts "Bye bye on #{Time.now}"
  end
end