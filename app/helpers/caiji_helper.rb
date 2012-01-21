#coding:utf-8
require 'socket'

module CaijiHelper
  include CitiesHelper
  def prepare_for_rule(logname)
    @logger=Logger.new(logname)
    @mechanize=Mechanize.new
    @mechanizeb=Mechanize.new
    
    Object::RUBY_PLATFORM.match("linux") ? (@office=false; @production=true)  :@office=true #linux did not need proxy
   
    @office=false if Socket.gethostname=="4f200ee3a49f435"
    puts "office mode=#{@office}"
    
    @mechanize.set_proxy("wwwgate0-ch.mot.com", 1080) if @office==true
    @mechanizeb.set_proxy("wwwgate0-ch.mot.com", 1080) if @office==true
    @mechanize.cookie_jar.load_cookiestxt(StringIO.new($cookie))  
    @mechanize.user_agent_alias = 'Windows Mozilla'
  end

  def set_cookie(domain,name,value)
    cookie = Mechanize::Cookie.new(name, value)
    cookie.domain = domain
    cookie.path = "/"
    @mechanize.cookie_jar.add(@mechanize.history.last.uri,cookie) #we have to run get before we set cookie ,otherwise will have nil error
  end
  
  def city_parse(from_city,to_city)
    city_array=Array.new
    city_array[0]=CityTree.get_code_from_name(from_city) unless from_city.blank?
    city_array[1]=CityTree.get_code_from_name(to_city) unless to_city.blank?
    city_array[2]=(city_array[0]||"")+"#"+(city_array[1]||"")
    #change to our name
   city_array[3]=get_city_full_name(city_array[0]) unless city_array[0].blank?
   city_array[4]=get_city_full_name(city_array[1]) unless city_array[1].blank?
    # we need store those unknow city, try recognize them by mannual
    [city_array[0],city_array[1],city_array[2],city_array[3],city_array[4]]      
  end
  
  def guess_line(from,to)
   city_from_code=CityTree.get_code_from_name(from) 
   city_to_code=CityTree.get_code_from_name(to) 
  return [city_from_code,city_to_code] 
 end

  def parse_56qq_line(line)

  all_line=Array.new
  raw_line=line.gsub(/\[|\]/,"")
  city_from=raw_line.split("-")[0]
  city_to=raw_line.split("-")[1].split(",")
  city_to.each do |tocity|
    all_line<<[city_from,tocity]
  end
 # convert all line to city code
 city_code_line=Array.new
 all_line.each do |line|
   city_code_line<<guess_line(line[0],line[1])
 end
 
 return city_code_line
end
  
end