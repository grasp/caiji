#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","helpers","contact_rules_helper.rb")
class Contact56110
  include ContactRulesHelper
  include CaijiHelper
end
contact=Contact56110.new
contact.prepare_for_rule("56110contact.log")
contact.run_56110_contact_rule

