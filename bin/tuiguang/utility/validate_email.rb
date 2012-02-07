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

 
def validate_format(email)
  if email.match(/^[a-zA-Z]([.]?([a-zA-Z0-9_-]+)*)?@([a-zA-Z0-9\-_]+\.)+[a-zA-Z]{2,4}$/)
    return true
  end
  return false
end


def validate_email_domain(email)
  domain = email.match(/\@(.+)/)[1]
  Resolv::DNS.open do |dns|
    @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
  end
  @mx.size > 0 ? true : false
end

$invalid=0;
$validated_domain=[]
start=Time.now

#LibEmail.where(:status.ne=>"disabled").each do |libemail|   
  Email.where(:valid=>nil).each do |email|   
  #validate format
  if not EmailAddressValidator.validate_with_regex(email.address)
    $invalid+=1
    puts "format #{email.address} not valid"
     email.update_attribute(:valid,false)
      next;
  end    
  
  #validate domain  and mail record of dns
  domain= email.address.split("@")[1]
  if not $validated_domain.include?(domain)
  if EmailAddressValidator.validate_with_dns(email.address) 
    $validated_domain<<domain   
    puts "valid dns =#{email.address}"    
      if EmailAddressValidator.validate_with_mx (email.address) 
        puts "valid mx record =#{email.address}"    
      else
         $invalid+=1
            puts "mx record #{email.address} not valid"
           email.update_attribute(:valid,false)
                next;
      end
  else
    $invalid+=1
    puts "DNS #{email.address} not valid"
     email.update_attribute(:valid,false)
     next;
  end
  else
 #   puts "already valid dns =#{email.address}"
   end
   
if not EmailCheck.run(email.address,"w090.001@gmail.com",domain).valid?
  $invalid+=1
  puts " emailbox #{email.address} not valid"
  email.update_attribute(:valid,false)
     next;
else
  email.update_attribute(:valid,true)
end

end
puts "invalide email=#{$invalid},cost time=#{Time.now-start}"
