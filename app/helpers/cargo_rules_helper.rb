#coding:utf-8
module CargoRulesHelper
  def prepare_for_rule
    @logger=Logger.new("cargorule.log")
    @mechanize=Mechanize.new
    @mechanizeb=Mechanize.new
    @mechanize.set_proxy(@proxy_server, 1080) if @office==true
    @mechanize.cookie_jar.load_cookiestxt(StringIO.new($cookie))  
    @mechanize.user_agent_alias = 'Windows Mozilla'
  end
  
  def set_cookie(domain,name,value)
      cookie = Mechanize::Cookie.new(name, value)
      cookie.domain = domain
      cookie.path = "/"
      @mechanize.cookie_jar.add(@mechanize.history.last.uri,cookie)
  end

  def run_tf56_rule
    @all_raw_cargo=Array.new    
    (7..16).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count.downto(1).each do |i| #each time we parse 4 page
      page = @mechanize.post(@cargo_rule.mainurl,{:me_page=>i}) #fetch the page,we get internal url by firefox firebug always,firefox may need latest version like version 8
      page.parser().css(@cargo_rule.maincss).each do |cargo_row|  #parser convert page into nokogiri object
        cargo_link=cargo_row.css("a").map { |link| link['href'] }  # this solution stole from internet stackover-flow question
        cargo_link=cargo_link[0]
        @mechanizeb.get("http://www.tf56.com/"+cargo_link) do |page|  #cargo information are all in page after open this link
          one_cargo=Hash.new
          parsed= page.parser.css("html body table table table table table table tr td.hytitle") #mannully map all information to ours
          one_cargo[:cate_name]=parsed[1].content unless parsed[1].blank? ;        one_cargo[:cargo_weight]=parsed[2].content   unless parsed[2].blank?
          one_cargo[:fcity_name]=parsed[3].content unless parsed[3].blank?;         one_cargo[:tcity_name]=parsed[4].content  unless parsed[4].blank?
          one_cargo[:comments]="车辆要求:"+parsed[5].content||"未说明" ;one_cargo[:contact]=parsed[6].content unless parsed[6].blank?    
          one_cargo[:fcity_code]=CityTree.get_code_from_name(one_cargo[:fcity_name]) unless one_cargo[:fcity_name].blank?
          one_cargo[:tcity_code]=CityTree.get_code_from_name(one_cargo[:tcity_name]) unless one_cargo[:tcity_name].blank?
          one_cargo[:created_at]=Time.now;   one_cargo[:send_date]=1           
          one_cargo[:from_site]="tf56";   one_cargo[:priority]=200
          one_cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
          one_cargo[:status]="正在配车"  # for match local
          #we need got fix phone and mphone infomation
       
          @all_raw_cargo<<one_cargo if  one_cargo.length>0   #at least something is there

          #  @logger.info  "parsed[2].content =#{parsed[2].content }" 
          #   @logger.info  "parsed[3].content =#{parsed[3].content }" 
          #   @logger.info  "parsed[4].content =#{parsed[4].content }"
          #   @logger.info  "parsed[5].content =#{parsed[5].content }"
          #   @logger.info "parsed[6].content =#{parsed[6].content }"
          #   @logger.info "parsed[7].content =#{parsed[7].content }"
    
        end
      end
    end
    #  @logger.info "all_raw_cargo.size=#{ @all_raw_cargo.size}"
    #post process for those information we get, translate fcity code
    #save database and post those successful
  end
  
  def run_56qq_rule
      @all_raw_cargo=Array.new 
      #cid	-1 fs	30 pid	11

      pid_list=[11,12,13,15,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,41,42,43,51,52,53,54,61,62,63,64,65]
      
       @mechanize.cookies.each do |cookie|
          if cookie.domain=="www.56qq.cn"
             @logger.info   cookie.name
             @logger.info   cookie.value
         end
       end
     @mechanize.get("http://www.56qq.cn") do |page| 
     end
     
      pid_list.each do |pid|
      set_cookie("www.56qq.cn","pid",pid)
     set_cookie("www.56qq.cn","cid",-1)  
      @mechanize.get("http://www.56qq.cn") do |page| 
      page.parser.css("div.entry").each do |entrycontainer|
      @logger.info [ entrycontainer.css("span.entry_city").text.strip.gsub(/\r\n/,"")  ,
        entrycontainer.css("span.spanentry_text").text.strip.gsub(/\r\n/,"") ,
        entrycontainer.css("span.cred").text.strip.gsub(/\r\n/,"")  
      ]      
    end
 end

    end
   
  end
  
  def run_cargorule    
    prepare_for_rule
    case @cargo_rule.rulename
    when "tf56cargo"
      run_tf56_rule
    when "56qqcargo"
      run_56qq_rule

    else
    end
  
  end

end
