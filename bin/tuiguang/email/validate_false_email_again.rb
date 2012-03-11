#coding:utf-8
require 'rubygems'

require 'pathname'
require 'forever'

require 'resolv'
require 'email_address_validator'#check format ,domain and mx record
require 'email_check' #connect to email server to check

pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

require File.join(project_root,"app","models","contact_rule.rb")
require File.join(project_root,"app","models","contact.rb")
require File.join(project_root,"app","models","email.rb")
require File.join(project_root,"app","helpers","contact_rules_helper.rb")

$format_invalid_nil=0
$format_invalid_not_nil=0  
$not_valid_domain=0
$not_valid_response=0

#decide validate which part
$validate_format=false
$validate_dns=true
$validate_response=true

#some utility global
$validated_domain=[]  #not validate domain again
start=Time.now
  
def validate_format(email)
  if email.match(/^[a-zA-Z]([.]?([a-zA-Z0-9_-]+)*)?@([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,4}$/)
    return true
  end

  return false
end



$invalid=0;

 
Email.where(:valid=>false).each do |email|   
  #validate email format

  unless EmailAddressValidator.validate_2822_addr(email.address,false)
    $invalid+=1
    puts "#{email.address} is  not valid"
    email.address.nil? ? $format_invalid_nil+=1 :  $format_invalid_not_nil+=1
    email.update_attribute(:valid,false)
    next;
  else
    puts "we found #{email.address} is true"
    email.update_attribute(:valid,true)
    puts "email.valid=#{email.valid}"
  end    

end
puts "not valide=#{Email.where(:valid=>false).count}"
puts "valide=#{Email.where(:valid=>true).count}"
puts "$format_invalid_nil=#{$format_invalid_nil},$format_invalid_not_nil=#{$format_invalid_not_nil},cost time=#{Time.now-start}"
puts "$not_valid_domain=#{$not_valid_domain},cost time=#{Time.now-start}"
puts "invalide email=#{$invalid},cost time=#{Time.now-start}"
