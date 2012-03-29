#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","models","email.rb")

require File.join(project_root,"app","helpers","contact_rules_helper.rb")
#puts "project_root=#{project_root}"
#for each contact get email and put it into email for tuiguang
Contact.where(:email.ne=>nil,:genemail.ne=>true).each do |contact|
  if contact.email.match(/@/) 
    Email.create(:address=>contact.email) 
  end
     contact.update_attribute(:genemail,true)
end

