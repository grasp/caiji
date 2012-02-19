#coding:utf-8
require 'rubygems'
require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")



Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
    every 1.day, :at => ['11:40'] do
     system("cd /opt/daily_backup")
     command="wget -c -O /opt/daily_backup/#{Time.now.to_s.slice(0,10)}.tgz http://w090.com/admin/backup_db/8978493982471"
      system(command)
   sleep 60*10
   
    end
  
  
    on_error do |e|
    puts "Boom raised: #{e.message} #{Time.now}"
  end

  on_exit do
    puts "Bye bye on #{Time.now}"
  end
end
