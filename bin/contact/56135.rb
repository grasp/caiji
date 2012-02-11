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
class Contact56135
  include ContactRulesHelper
  include CaijiHelper
end
contact56135=Contact56135.new
contact56135.prepare_for_rule("56135contact.log")
contact56135.run_56135_contact_rule

