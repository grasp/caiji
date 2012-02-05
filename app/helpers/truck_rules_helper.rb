#coding:utf-8
module TruckRulesHelper  
  include CaijiHelper  
  def run_tf56_truck_rule
    @all_raw_truck=Array.new
    (7..16).include?(Time.now.hour) ? @page_count=5 : @page_count=1  #in busy time ,we need fetch more page       
    @page_count.downto(1).each do |i|
      @mechanize.get("http://www.tf56.com/wscy.asp",{:me_page=>i}) do |page|
        page.parser().css("tr td.hydash:first").each do |tr|
          one_truck=Hash.new
          #  @logger.info tr.content
          url=tr.css("a").map { |link| link['href'] }         
          unless url.nil?
            url="http://www.tf56.com/"+"TradeCenter/AspData/tCarDetail.asp?iWebBizCarID="+url[0].to_s[-6..-1]
            #  @logger.info url
            @mechanizeb.get(url) do |page2|
              page2.parser.css("html body table tr").each do |tr|               
                parsed=Array.new
                tr.css("td").each do |td|
                  parsed<< td.content
                end
                #  parsed.each_index do |index|
                #  @logger.info "index#{index}=#{parsed[index]}"
                #  end                
                one_truck[:paizhao]=parsed[2] if (parsed[1]||"").match("车牌号码")
                one_truck[:dunwei]=parsed[2] if (parsed[1]||"").match("吨位")
                one_truck[:dunwei]=one_truck[:dunwei].gsub("吨","") if (one_truck[:dunwei]||"").match("吨")
                one_truck[:length]=parsed[2] if (parsed[1]||"").match("车长")
                one_truck[:length]=one_truck[:length].gsub("米","") if (one_truck[:length]||"").match("米")
                one_truck[:fcity_name]=parsed[2] if (parsed[1]||"").match("出发地")
                one_truck[:tcity_name]=parsed[2] if (parsed[1]||"").match("到达地")                                
                one_truck[:contact]="" if  one_truck[:contact].nil?
                if (parsed[1]||"").match("手机")
                  one_truck[:contact]<<(parsed[2]||"") 
                  one_truck[:mobilephone]="" if  one_truck[:mobilephone].nil?
                  one_truck[:mobilephone]<<(one_truck[:contact].match(/\d\d\d\d\d\d\d\d\d\d\d/).to_s||"" +",")   if one_truck[:contact].size>10                 
                end                
                one_truck[:comments]="" if one_truck[:comments].blank?
                one_truck[:comments]<<(parsed[2]||"") if (parsed[1]||"").match("车况介绍")     
                
                one_truck[:status]="正在配货"  # for match local
                one_truck[:from_site]="tf56"
                one_truck[:priority]=200
                one_truck[:send_date]=1
                one_truck[:huicheng]="003"
                one_truck[:user_id]="4e24c1d47516fd513c000002" #admin id            
              end
            end
            #split to city to each line            
            arrivecity=String.new(one_truck[:tcity_name])
            arrivecity.delete(">").split.each do |arrive_city|
              another_truck=Hash.new #copy and paste
              one_truck.each do |key,value|
                another_truck[key]=value
              end
              #  @logger.info "handle city #{arrive_city}"
              city_array=city_parse(another_truck[:fcity_name],arrive_city)
              another_truck[:fcity_code]=city_array[0]; another_truck[:tcity_code]=city_array[1]; another_truck[:line]=city_array[2]
              another_truck[:fcity_name]=city_array[3];another_truck[:tcity_name]=city_array[4]
              @all_raw_truck<<another_truck
            end
           
          end
        end
      end
    end    
    save_truck(@all_raw_truck)
  end
  
  def run_56qq_truck_rule
    @all_raw_truck=Array.new
    pid_list=[11,12,13,15,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,41,42,43,51,52,53,54,61,62,63,64,65]      
    @mechanize.cookies.each do |cookie|  #56qq use javascript to write pid into cookie to judge which province or city user want to view,so we have to do by ourself
      if cookie.domain=="www.56qq.cn"
        #  @logger.info   cookie.name
        #  @logger.info   cookie.value
      end
    end
    @mechanize.get("http://www.56qq.cn")# do |page|  #for generate a history, so setcookie will not raise history empty exception
    #  end     
    pid_list.each do |pid|
      set_cookie("www.56qq.cn","pid",pid)
      set_cookie("www.56qq.cn","cid",-1)  
      @mechanize.get("http://www.56qq.cn") do |page| 
        page.parser.css("div.entry").each do |entrycontainer|
          timetag=entrycontainer.css("div.entry_date").text
          raw_array= [ entrycontainer.css("span.entry_city").text.strip.gsub(/\r\n/,"")  ,
            entrycontainer.css("span.spanentry_text").text.strip.gsub(/\r\n/,"") ,
            entrycontainer.css("span.cred").text.strip.gsub(/\r\n/,"")  
          ]        
   
          parse_56qq_line(raw_array[0]).each do |line|
            if raw_array[1].match("车源信息")
              # @logger.info "raw_array0=#{raw_array[0]},raw_array1=#{raw_array[1]},raw_array0=#{raw_array[2]}"
              onetruck=[line,raw_array[1], raw_array[2]]
              if !onetruck[0][0].nil? and !onetruck[0][1].nil?
                one_truck=Hash.new 
                one_truck[:fcity_code]=onetruck[0][0]
                one_truck[:tcity_code]=onetruck[0][1]
                one_truck[:line]=(one_truck[:fcity_code]||"")+"#"+(one_truck[:tcity_code]||"")
                one_truck[:fcity_name]=CityTree.get_city_full_path(one_truck[:fcity_code])
                one_truck[:tcity_name]=CityTree.get_city_full_path(one_truck[:tcity_code])  
                #   @logger.info "#{cargo[:fcity_name]}-#{cargo[:tcity_name]}"
                one_truck[:comments]=onetruck[1].gsub(/车源信息：/,"").gsub(/备注内容：/,"").gsub(/联系我时，请说是在56QQ上看到的，谢谢！/,"").gsub(/\s/,"")
                one_truck[:length]=onetruck[1].match(/\d(\.)\d米/).to_s
                one_truck[:dunwei]=onetruck[1].match(/...吨/).to_s
                one_truck[:paizhao]=one_truck[:comments].match(/车牌号为.......车/) unless one_truck[:comments].blank?
                one_truck[:contact]=onetruck[2].gsub(/TEL\:/,"") 
                one_truck[:paizhao]="未知牌照" if one_truck[:paizhao].blank?
                #fetch mobilephone and fixphone
                one_truck[:mobilephone]=one_truck[:contact].match(/1\d\d\d\d\d\d\d\d\d\d/).to_s
                one_truck[:fixphone]=one_truck[:contact].match(/\d\d\d+-\d\d\d\d\d\d\d+/).to_s  
                one_truck[:send_date]=1
                one_truck[:from_site]="56qq"
                one_truck[:created_at]=Time.now
                one_truck[:status]="正在配货"  # for match local
                one_truck[:priority]=300
                one_truck[:timetag]=timetag # which time it is generated
                a=Time.now
                if timetag.match("上午")||timetag.match("下午")
                  one_truck[:timetag]=a.month.to_s+"月"+a.day.to_s+"日"+timetag                                
                end
                if timetag.match("昨天")
                  a=a-86400
                  one_truck[:timetag]=a.month.to_s+"月"+a.day.to_s+"日"+timetag.delete("昨天")                                
                end
                one_truck[:user_id]="4e24c1d47516fd513c000002" #admin id
                @all_raw_truck<<one_truck if  one_truck.length>0   #at least something is there              
              end
            end
          end  
        end
      end
    end   
    save_truck(@all_raw_truck)
  end
  
  def run_56135_truck_rule
    @all_raw_truck=Array.new
  end
  
  def run_quzhou_truck_rule
    @all_raw_truck=Array.new
  end
  
  def run_haoyun_truck_rule
    @all_raw_truck=Array.new
  end
  
  def save_truck(all_raw_truck)
    # Truck.delete_all
    all_raw_truck.each do |truck|
      begin
        Truck.new(truck).save!
      rescue
        @logger.info "excetption on truck save"
        #  @logger.info $@
      end
    end
  end 
  def post_truck_helper(sitename)    
    @mechanize=Mechanize.new
    if @os.nil? || @office.nil?
      env_info=get_env_information #from caiji helper module
      @os=env_info[0];@office=env_info[1]
    end
    @logger=Logger.new("truckrule.log")
    @trucks=Array.new

    #Truck.all.each do |truck|
    #   truck.update_attributes("posted"=>nil) #need set to yes after post
    #end
    if sitename
      Truck.where(:posted=>nil,:from_site=>sitename).each do |truck|   
        id=truck.id.to_s
        hash={}
        truck.instance_variables.each {|var| hash[var.to_s.delete("@")] = truck.instance_variable_get(var) }
        second_hash= hash["attributes"]
        second_hash.delete("_id")
        second_hash.delete("created_at")
        second_hash.delete("updated_at")
        second_hash.delete("posted")
        @logger.info second_hash
        if @os=="linux" && @office==true  
          @mechanize.set_proxy("wwwgate0-ch.mot.com", 1080) 
          @mechanize.post("http://w090.com/trucks/post_truck",:truck=>second_hash)        
      
        end
        
        @mechanize.post("http://127.0.0.1:4500/trucks/post_truck",:truck=>second_hash) if @os=="windows" && @office==true     
    
  
        truck.id=id  #I dont know why we need this ,due to I see id was set to nil before udpate
        #  @logger.info "cargo.id=#{cargo.id}"
        truck.update_attributes("posted"=>"yes") #need set to yes after post
        # @logger.info "post done"
        @trucks<<truck
      end
    end
  end
  def run_truckrule(sitename,rulename)
    prepare_for_rule("./log/#{rulename}.log")
    case rulename
    when "tf56truck"
      run_tf56_truck_rule
    when "56qqtruck"
      run_56qq_truck_rule      
    when "56135truck"
      run_56135_truck_rule
    when "quzhoutruck"
      run_quzhou_truck_rule
    when "haoyuntruck"
      run_haoyun_truck_rule
    else
    end
  end
  def cron_run_truck_rule(sitename,rulename)
    @truck_rule=TruckRule.where(:sitename=>sitename,:rulename=>rulename).first  
    raise if  @truck_rule.blank?
    run_truckrule(sitename,rulename)
    post_truck_helper(sitename)    
  end  
end
