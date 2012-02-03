#coding:utf-8
require 'socket'

module CaijiHelper
  include CitiesHelper
  
    def get_env_information        
    Object::RUBY_PLATFORM.match("linux") ? @os="linux": @os="windows"
    if @os=="windows"
      ipconfig=`ipconfig -all |grep DNS`
      ipconfig.match(/ds\.mot\.com/mi) ? @office=true : @office=false
    end
    
    if @os=="linux"
      ipconfig=`ifconfig -a`
      ipconfig.match(/10\.192/mi) ? @office=true : @office=false
    end
    return [@os,@office]
  end
  
  def get_cookie_dir
    if @os.nil? || @office.nil?
      env_info=get_env_information
      @os=env_info[0];@office=env_info[1]
    end
    cookie_dir ="C:\\Documents and Settings\\Administrator\\Application Data\\Mozilla\\Firefox\\Profiles\\tttk3240.default"  if @os=="windows" && @office==false
    cookie_dir ="D:\\Profiles\\w22812\\Application Data\\Mozilla\\Firefox\\Profiles\\623tc49u.default"   if @os=="windows" && @office==true
    cookie_dir="/home/netmon/ului265f"   if @os=="linux" && @office==true
    cookie_dir ="/home/hunter/.mozilla/firefox/h9tayj2y.default" if @os=="linux" && @office==false
    $cookie_dir=cookie_dir
    return cookie_dir
  end
  
  def load_cookie
    $cookie_dir=get_cookie_dir if $cookie_dir.nil?
    if $cookie.nil?
    cookie = String.new  
    Dir.chdir($cookie_dir){|dir|  
      db = SQLite3::Database.new('cookies.sqlite')  
      p = Proc.new{|s| s.to_i.zero? ? 'TRUE' : 'FALSE'}  
      db.execute("SELECT  host, isHttpOnly, path, isSecure, expiry, name, value FROM moz_cookies   
    ORDER BY id DESC"){|r|  
        cookie << [r[0], p.call(r[1]), r[2], p.call(r[3]), r[4], r[5], r[6]].join("\t") << "\n"  
      }  
    }  
    $cookie= cookie
    end
    return $cookie
  end
  

  
  def prepare_for_rule(logname)
    @logger=Logger.new(logname)
    
    @mechanize=Mechanize.new; 
    
    @mechanizeb=Mechanize.new
    
    if @os.nil? || @office.nil?
      env_info=get_env_information
      @os=env_info[0];@office=env_info[1]
    end
    
    @mechanize.set_proxy("wwwgate0-ch.mot.com", 1080) if @office==true
    @mechanizeb.set_proxy("wwwgate0-ch.mot.com", 1080) if @office==true
    if  @office==true
@proxy="http://wwwgate0-ch.mot.com:1080" 
else
  @proxy=nil
end
    
    @mechanize.cookie_jar.load_cookiestxt(StringIO.new(load_cookie))  
  @mechanize.user_agent_alias = 'Windows Mozilla'
  #   @mechanize.user_agent_alias = 'Windows IE 6'
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
