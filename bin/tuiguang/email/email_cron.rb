#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
require "action_mailer"
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","models","email.rb")
require File.join(project_root,"app","mailers","notifier.rb")
require File.join(project_root,"app","models","tuiguang_stats.rb")

require File.join(project_root,"config","initializers","init","cargo_big_category_load.rb")
require File.join(project_root,"config","initializers","init","cargo_category_load.rb")
require File.join(project_root,"config","initializers","init","cargo_option_load.rb")
require File.join(project_root,"config","initializers","init","truck_shape_load.rb")
require File.join(project_root,"config","initializers","init","truck_pinpai_load.rb")
require File.join(project_root,"config","initializers","init","truck_huicheng.rb")
$project_root=project_root
#define mail sent env
ActionMailer::Base.smtp_settings = {
  :user_name => "w090.mark",
  :password => "999317",
  :domain => "w090.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
ActionMailer::Base.delivery_method = :smtp


def send_one_tuiguang_email(email)
  Notifier.tuiguang_email(email).deliver!
end

def mail_cron
Email.where(:valid.ne=>false,:scount=>nil).limit(1).each do |email|
  daily_count=Email.where(:valid.ne=>false,:scount=>1,:updated_at.gte=>Time.now.at_beginning_of_day).count
  if daily_count>3000 #daily sent 3000
    break;
  else
   send_one_tuiguang_email(email.address)
#    send_one_tuiguang_email("hunter.wxhu@gmail.com")
    email.update_attribute(:scount,1)
  end
end
end

Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
  every 1.minutes do
    begin
    mail_cron
    rescue
      puts "mail sent error!"
    end    
  end
 every 1.day, :at => ['10:00'] do
   Notifier.tuiguang_email("hunter.wxhu@gmail.com").deliver!
   Notifier.tuiguang_email("179743816@qq.com").deliver!
  end
  on_error do |e|
    puts "Boom raised: #{e.message} #{Time.now}"
  end

  on_exit do
    puts "Bye bye on #{Time.now}"
  end
end


