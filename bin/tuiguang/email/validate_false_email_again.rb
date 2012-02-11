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
$validate_response=false

#some utility global
$validated_domain=[]  #not validate domain again
start=Time.now
  
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

 
Email.where(:valid=>false).each do |email|   
  #validate email format
  if $validate_format
    unless EmailAddressValidator.validate_with_regex(email.address)
      $invalid+=1
      # puts "#{email.address} format  not valid"
      email.address.nil? ? $format_invalid_nil+=1 :  $format_invalid_not_nil+=1
      email.update_attribute(:valid,false)
      next;
    end    
  end
  
  if $validate_dns
    #validate domain  and mail record of dns
  domain=String.new
  if email.address.nil? #not check if nil
   $not_valid_domain+=1
   next
  else
    domain=email.address.split("@")[1] 
   end
  next if $validated_domain.include?(domain) # if already checked
    unless $validated_domain.include?(domain)
      if EmailAddressValidator.validate_with_dns(email.address) 
        $validated_domain<<domain   
      #  puts "valid dns =#{email.address}"    
        if EmailAddressValidator.validate_with_mx (email.address) 
         # puts "valid mx record =#{email.address}"    
        else
          $not_valid_domain+=1
          puts "mx record #{email.address} not valid"
          email.update_attribute(:valid,false)
          next;
        end
      else
       $not_valid_domain+=1
        puts "DNS #{email.address} not valid"
        email.update_attribute(:valid,false)
        next;
      end
    else
      #   puts "already valid dns =#{email.address}"
    end
  end
  
  if $validate_response
    unless EmailCheck.run(email.address,"w090.001@gmail.com",domain).valid?
      $invalid+=1
      puts " emailbox #{email.address} not valid"
      email.update_attribute(:valid,false)
      next;
    else
      email.update_attribute(:valid,true)
    end
  end
end
puts "$format_invalid_nil=#{$format_invalid_nil},$format_invalid_not_nil=#{$format_invalid_not_nil},cost time=#{Time.now-start}"
puts "$not_valid_domain=#{$not_valid_domain},cost time=#{Time.now-start}"
puts "invalide email=#{$invalid},cost time=#{Time.now-start}"
