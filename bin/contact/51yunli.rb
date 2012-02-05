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
class Contact51yunli
  include ContactRulesHelper
  include CaijiHelper
end
contact=Contact51yunli.new
contact.prepare_for_rule("51yunlicontact.log")
contact.run_yunli51_contact_rule

