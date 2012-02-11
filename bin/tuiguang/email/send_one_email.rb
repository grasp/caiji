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

send_one_tuiguang_email("hunter.wxhu@gmail.com")

