#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","models","mphone.rb")

require File.join(project_root,"app","helpers","contact_rules_helper.rb")
#puts "project_root=#{project_root}"
#for each contact get email and put it into email for tuiguang




10.downto(0).each do |i|
  begin
Contact.where(:gen.ne=>"phone",:mphone.ne=>nil).each do |contact|
  if contact.mphone.match(/\d\d\d\d\d\d\d\d\d\d\d/)
    if Mphone.where(:mphone=>contact.mphone).count==0
    Mphone.create(:mphone=>contact.mphone,:operator=>get_operator(contact.mphone)) 
    puts "update #{contact.mphone}"
    contact.update_attribute(:gen,"phone")
    end
  end
end
  rescue
    next
  end
end

