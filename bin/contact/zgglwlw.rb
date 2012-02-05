#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","helpers","contact_rules_helper.rb")
class Contactzgglwlw
  include ContactRulesHelper
  include CaijiHelper
end
contact=Contactzgglwlw.new
contact.prepare_for_rule("zgglwlwcontact.log")
contact.run_zgglwlw_contact_rule

