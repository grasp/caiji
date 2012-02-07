#coding:utf-8
module CargoRulesHelper
  include CaijiHelper
  def run_tf56_cargo_rule
  #  @logger.info "run tf56cargo"
    @all_raw_cargo=Array.new    
    (7..16).include?(Time.now.hour) ? @page_count=5 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count.downto(1).each do |i| #each time we parse 3 page
      page = @mechanize.post("http://www.tf56.com/wshy.asp",{:me_page=>i}) #fetch the page,we get internal url by firefox firebug always,firefox may need latest version like version 8
      page.parser().css("html body table table table table table tr td.hydash:first").each do |cargo_row|  #parser convert page into nokogiri object  
        cargo_link=cargo_row.css("a").map { |link| link['href'] }  # this solution stole from internet stackover-flow question
        cargo_link=cargo_link[0]
     #   @logger.info "cargo_link=#{cargo_link}"
        next if cargo_link.blank? #ignore those unexisited link 
      
        @mechanizeb.get("http://www.tf56.com/"+cargo_link) do |page|  #cargo information are all in page after open this link
          one_cargo=Hash.new
          parsed= page.parser.css("html body table table table table table table tr td.hytitle") #mannully map all information to ours
          one_cargo[:cate_name]=parsed[1].content unless parsed[1].blank? ;        one_cargo[:cargo_weight]=parsed[2].content   unless parsed[2].blank?
          one_cargo[:fcity_name]=parsed[3].content unless parsed[3].blank?;         one_cargo[:tcity_name]=parsed[4].content  unless parsed[4].blank?
          one_cargo[:fcity_name]=get_city_full_name(one_cargo[:fcity_code]) unless one_cargo[:fcity_code].nil?
          one_cargo[:tcity_name]=get_city_full_name(one_cargo[:tcity_code]) unless one_cargo[:tcity_code].nil?
          unless parsed[5].blank?
            unless parsed[5].content.blank?
              one_cargo[:comments]="车辆要求:"+ parsed[5].content 
            else
              one_cargo[:comments]="车辆要求:"+ "未说明";
            end             
          else
            one_cargo[:comments]="车辆要求:"+ "未说明";
          end
          
          one_cargo[:contact]=parsed[6].content unless parsed[6].blank?    
          one_cargo[:timetag]=parsed[7].content unless parsed[7].blank?    
           
          city_array=city_parse(one_cargo[:fcity_name],one_cargo[:tcity_name])
          one_cargo[:fcity_code]=city_array[0]; one_cargo[:tcity_code]=city_array[1]; one_cargo[:line]=city_array[2]
          
          one_cargo[:created_at]=Time.now;   one_cargo[:send_date]=1           
          one_cargo[:from_site]="tf56";   one_cargo[:priority]=200
          one_cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
          one_cargo[:status]="正在配车"  # for match local
          #we need got fix phone and mphone infomation, this for statistic how many cargo been published by one phone
          unless one_cargo[:contact].blank?
            if one_cargo[:contact].match(/\[\d+\]/)
              one_cargo[:fixphone]= one_cargo[:contact].match(/\[\d+\]/).to_s.gsub("[","").gsub("]","").to_s+"-"+one_cargo[:contact].match(/\d\d\d\d\d\d\d\d/).to_s
            end
            if one_cargo[:contact].match(/\d\d\d\d\d\d\d\d\d\d\d/)
              one_cargo[:mobilephone]= one_cargo[:contact].match(/\d\d\d\d\d\d\d\d\d\d\d/).to_s
            end
          end
          if one_cargo[:mobilephone].blank? #try comments , sometimes phone is in comments
            one_cargo[:mobilephone]=one_cargo[:comments].match(/\d\d\d\d\d\d\d\d\d\d\d/).to_s
          end
          @all_raw_cargo<<one_cargo if  one_cargo.length>0   #at least something is there
          #  @logger.info  "parsed[2].content =#{parsed[2].content }" 
          #   @logger.info  "parsed[3].content =#{parsed[3].content }" 
          #   @logger.info  "parsed[4].content =#{parsed[4].content }"
          #   @logger.info  "parsed[5].content =#{parsed[5].content }"
          #  @logger.info "parsed[6].content =#{parsed[6].content }"
          #   @logger.info "parsed[7].content =#{parsed[7].content }"
    
        end
      end
    end
    #  @logger.info "all_raw_cargo.size=#{ @all_raw_cargo.size}"
    #post process for those information we get, translate fcity code
    #save database and post those successful    
    save_cargo(@all_raw_cargo)
  end
  
  def run_56qq_cargo_rule
    @all_raw_cargo=Array.new 
    #cid	-1 fs	30 pid	11
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
            if raw_array[1].match("货源信息")
              onecargo=[line,raw_array[1], raw_array[2]]
              if !onecargo[0][0].nil? and !onecargo[0][1].nil?
                cargo=Hash.new 
                cargo[:fcity_code]=onecargo[0][0]
                cargo[:tcity_code]=onecargo[0][1]
                cargo[:line]=(cargo[:fcity_code]||"")+"#"+(cargo[:tcity_code]||"")
                cargo[:fcity_name]=get_city_full_name(cargo[:fcity_code]) unless cargo[:fcity_code].nil?
                cargo[:tcity_name]=get_city_full_name(cargo[:tcity_code]) unless cargo[:tcity_code].nil? 
                #   @logger.info "#{cargo[:fcity_name]}-#{cargo[:tcity_name]}"
                cargo[:comments]=onecargo[1].gsub(/货源信息：/,"").gsub(/备注内容：/,"").gsub(/联系我时，请说是在56QQ上看到的，谢谢！/,"").gsub(/\s/,"")
                cargo[:cargo_weight]=onecargo[1].match(/\d\d\d吨|\d\d吨|\d吨|\d方|\d\d方/).to_s
                cargo[:cate_name]=cargo[:comments].to_s[-10..-1]
                cargo[:contact]=onecargo[2].gsub(/TEL\:/,"") 
      
                #fetch mobilephone and fixphone
                cargo[:mobilephone]=cargo[:contact].match(/1\d\d\d\d\d\d\d\d\d\d/).to_s
                cargo[:fixphone]=cargo[:contact].match(/\d\d\d+-\d\d\d\d\d\d\d+/).to_s  
                cargo[:send_date]=1
                cargo[:from_site]="56qq"
                cargo[:created_at]=Time.now
                cargo[:status]="正在配车"  # for match local
                cargo[:priority]=300
                cargo[:timetag]=timetag # which time it is generated
                a=Time.now
                if timetag.match("上午")||timetag.match("下午")
                  cargo[:timetag]=a.month.to_s+"月"+a.day.to_s+"日"+timetag                                
                end
                if timetag.match("昨天")
                  a=a-86400
                  cargo[:timetag]=a.month.to_s+"月"+a.day.to_s+"日"+timetag.delete("昨天")                                
                end
                cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
                @all_raw_cargo<<cargo if  cargo.length>0   #at least something is there              
              end
            end
          end  
        end
      end
    end   
    save_cargo(@all_raw_cargo)
  end
  
  def run_56135_cargo_rule
    @all_raw_cargo=Array.new 
    (7..16).include?(Time.now.hour) ? @page_count=5 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count.downto(1).each do |i| #each time we parse 3 page
      @mechanize.get("http://www.56135.com/56135/trade/tradeindex///#{i}.html") do |page|
        page.parser.css("div.info_show").each do |entrycontainer|
          cargo=Hash.new    
          lininfo=entrycontainer.css("div.area").text.to_s
          from_name= lininfo.to_s.match(/起运地.*目的地/u).to_s
          to_name= lininfo.to_s.gsub(from_name,"").gsub("：","").gsub("-","").gsub("  ","").to_s
          from_name=from_name.gsub("起运地","").gsub("目的地","").gsub("：","").gsub("-","").gsub("  ","").to_s

          cargo[:fcity_name]=from_name
          cargo[:tcity_name]=to_name
          city_array=city_parse(cargo[:fcity_name],cargo[:tcity_name])
          cargo[:fcity_code]=city_array[0]; cargo[:tcity_code]=city_array[1]; cargo[:line]=city_array[2]
           cargo[:fcity_name]=get_city_full_name(cargo[:fcity_code]) unless cargo[:fcity_code].nil?
            cargo[:tcity_name]=get_city_full_name(cargo[:tcity_code]) unless cargo[:tcity_code].nil? 
      
          packinfo=entrycontainer.css("div.c_line").text.match(/货品属性.*$/u).to_s
          raw_array0= packinfo.match(/货品属性：.*重量：/u).to_s.gsub("货品属性：","").gsub("重量：","").to_s      
          raw_array3= packinfo.match(/重量：.* 吨/u).to_s.gsub("重量：","").gsub("吨","").to_s
          raw_array5= entrycontainer.css("div.c_name").text.match(/^.*交易状态/u).to_s.gsub("交易状态","").to_s

          raw_array6= entrycontainer.css("div.c_main_r").text
          raw_array7 =entrycontainer.css("div.c_btm").text.to_s
     
          cargo[:contact]=raw_array6
          cargo[:comments]=raw_array5.to_s+raw_array6.to_s+raw_array7.to_s
          cargo[:mobilephone]=cargo[:comments].match(/1\d\d\d\d\d\d\d\d\d\d/).to_s
          cargo[:fixphone]=cargo[:comments].match(/\d\d\d+-\d\d\d\d\d\d\d+/).to_s 
          cargo[:cargo_weight]=raw_array3
          cargo[:cate_name]=raw_array5
          cargo[:send_date]=1
          cargo[:from_site]="56135"
          cargo[:created_at]=Time.now
          cargo[:status]="正在配车"  # for match local
          cargo[:priority]=500
          cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
          @all_raw_cargo<<cargo unless cargo.blank?
        end
      end
    end
    save_cargo(@all_raw_cargo)
  end
  
  def run_quzhou_cargo_rule
    @all_raw_cargo=Array.new 
    (7..16).include?(Time.now.hour) ? @page_count=5 : @page_count=1  #in busy time ,we need fetch more page     
    @page_count.downto(1) do |i|
      @mechanize.get("http://56.qz56.com:8081/wl/UserQueryData.jsp?offset=#{i}&likestr=") do |page|      
        page.parser().css("html body div table tbody tr td table tr").each do |tr|
        #  @logger.info "start a new cargo"
          one_cargo=Hash.new
          one_item_array=Array.new
          tr.css("td").each do |td|
            one_item_array<<td.content     
          end           
        #  one_item_array.each_index do |i|
          #  @logger.info "index#{i}= #{one_item_array[i]}"
        #  end
          unless one_item_array[0].blank?
            if one_item_array[0].match("货物")#marked as cargo
              one_cargo[:cate_name]=(one_item_array[1]||"未知货物").strip  
              one_cargo[:cate_name]="货物未知" if one_cargo[:cate_name].size==0
              one_cargo[:fcity_name]=(one_item_array[2]||"未知城市").strip
              one_cargo[:tcity_name]=(one_item_array[3]||"未知城市").strip
              
              city_array=city_parse(one_cargo[:fcity_name],one_cargo[:tcity_name])
              one_cargo[:fcity_code]=city_array[0]; one_cargo[:tcity_code]=city_array[1]; one_cargo[:line]=city_array[2]
               one_cargo[:fcity_name]=get_city_full_name(one_cargo[:fcity_code]) unless one_cargo[:fcity_code].nil?
                one_cargo[:tcity_name]=get_city_full_name(one_cargo[:tcity_code]) unless one_cargo[:tcity_code].nil? 
              one_cargo[:cargo_weight]=(one_item_array[4]||"0").strip+(one_item_array[5]||"").strip
              one_cargo[:price]=(one_item_array[6]||"0").strip+(one_item_array[7]||"").strip
              one_cargo[:comments] = "车辆要求"+(one_item_array[8]||"0").strip+(one_item_array[9]||"").strip
              one_cargo[:mobilephone]=one_item_array[11].strip.match(/1\d\d\d\d\d\d\d\d\d\d/).to_s
              one_cargo[:fixphone]=one_item_array[11].strip.match(/^\d\d\d\d\d\d\d$/).to_s 
              if one_cargo[:fixphone].size>0
                one_cargo[:fixphone]="0570-"+one_cargo[:fixphone]
              end              
              one_cargo[:contact] = (one_item_array[10]||"").strip+"-电话"+(one_cargo[:fixphone]||"")+one_cargo[:mobilephone]              
              one_cargo[:timetag] = (one_item_array[12]||"").strip
              one_cargo[:send_date]=1
              one_cargo[:from_site]="quzhou"
              one_cargo[:created_at]=Time.now
              one_cargo[:status]="正在配车"  # for match local
              one_cargo[:priority]=600 #not use for now
              one_cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
              @all_raw_cargo<<one_cargo if one_cargo.length>0
            end       
          end
             
        end
      end
    end   
    save_cargo(@all_raw_cargo)
  end
  
  def run_haoyun_cargo_rule
    @all_raw_cargo=Array.new 
    (7..16).include?(Time.now.hour) ? @page_count=5 : @page_count=1  #in busy time ,we need fetch more page     
    @page_count.downto(1).each do |i|
      @mechanize.get("http://peihuo.haoyun56.com/goods_p#{i}.html") do |page|
        page.parser.css("tr.list_list").each do |entry|
          two_row=[entry,entry.next_element]
          two_row.each do |entrycontainer|
            one_cargo=Hash.new
            raw_cargo=Array.new
            entrycontainer.css("td").each do |entrytd|
              raw_cargo<<entrytd.text.gsub(/\r\n/,"").gsub(/\s/,"")            
            end
          #  raw_cargo.each_index do |index|
          #    @logger.info  "index#{index}=#{raw_cargo[index]}"
          #  end
            one_cargo[:cate_name]=(raw_cargo[0]||"未知货物").strip  
            one_cargo[:fcity_name]=raw_cargo[1].strip   
            one_cargo[:tcity_name]=raw_cargo[2].strip  
            
            one_cargo[:cargo_weight]=raw_cargo[3].strip  
            one_cargo[:price]=raw_cargo[4].strip 
            one_cargo[:contact]=raw_cargo[5].strip 
            one_cargo[:comments]=raw_cargo[6].strip 
            one_cargo[:timetag]=raw_cargo[7].to_s
            one_cargo[:mobilephone]= one_cargo[:contact].strip.match(/1\d\d\d\d\d\d\d\d\d\d/).to_s
            one_cargo[:fixphone]= one_cargo[:contact].strip.match(/\d\d\d\d-\d\d\d\d\d\d\d+/).to_s
            city_array=city_parse(one_cargo[:fcity_name],one_cargo[:tcity_name])
            one_cargo[:fcity_code]=city_array[0]; one_cargo[:tcity_code]=city_array[1]; one_cargo[:line]=city_array[2]
              one_cargo[:fcity_name]=get_city_full_name(one_cargo[:fcity_code]) unless one_cargo[:fcity_code].nil?
                one_cargo[:tcity_name]=get_city_full_name(one_cargo[:tcity_code]) unless one_cargo[:tcity_code].nil? 
            one_cargo[:send_date]=1
            one_cargo[:from_site]="haoyun56"
            one_cargo[:created_at]=Time.now
            one_cargo[:status]="正在配车"  # for match local
            one_cargo[:priority]=700 #not use for now
            one_cargo[:user_id]="4e24c1d47516fd513c000002" #admin id
            @all_raw_cargo<<one_cargo      
          end
        end        
      end
    end
    save_cargo(@all_raw_cargo)
  end
  
  def save_cargo(all_raw_cargo)
      Cargo.delete_all
    all_raw_cargo.each do |cargo|
      begin
        if cargo[:cate_name].size >15
          cargo[:cate_name]=cargo[:cate_name][0,14]
        end
        Cargo.new(cargo).save!
      rescue
        @logger.info "excetption on cargo save"
        #  @logger.info $@
      end
    end
  end 
  
  def post_cargo_helper(sitename)    
    @mechanize=Mechanize.new
  
    if @os.nil? || @office.nil?
      env_info=get_env_information #from caiji helper module
      @os=env_info[0];@office=env_info[1]
    end
  #  @mechanize.set_proxy("wwwgate0-ch.mot.com", 1080)    if @os=="linux" && @office==true #in windows post to local server for debug
    @logger=Logger.new("cargorule.log")
    @cargos=Array.new
    if sitename
      Cargo.where(:posted=>nil,:from_site=>sitename).each do |cargo|
        id=cargo.id.to_s
        hash={}
        cargo.instance_variables.each {|var| hash[var.to_s.delete("@")] = cargo.instance_variable_get(var) }
        second_hash= hash["attributes"]
        second_hash.delete("_id")
        second_hash.delete("created_at")
        second_hash.delete("updated_at")
        second_hash.delete("posted")
        #  @logger.info second_hash
         begin
         @mechanize.post("http://w090.com/cargos/post_cargo",:cargo=>second_hash)  if @os=="linux" && @office==false
         rescue
         puts "post cargo Exception"
         end
         @mechanize.post("http://127.0.0.1:4500/cargos/post_cargo",:cargo=>second_hash)  if @os=="windows" && @office==false        
        
        cargo.id=id  #I dont know why we need this ,due to I see id was set to nil before udpate
        #  @logger.info "cargo.id=#{cargo.id}"
        cargo.update_attributes("posted"=>"yes")
        # @logger.info "post done"
        @cargos<<cargo
      end
    end
  end
  #change to conf mode
  
  def run_cargorule(rulename)    
     prepare_for_rule("#{rulename}"+".log")
    case rulename
    when "tf56cargo"
      run_tf56_cargo_rule
    when "56qqcargo"
      run_56qq_cargo_rule      
    when "56135cargo"
      run_56135_cargo_rule
    when "quzhoucargo"
      run_quzhou_cargo_rule
    when "haoyuncargo"
      run_haoyun_cargo_rule
    else
    end  
  end
  
  def cron_run_cargo_rule(sitename,rulename)
    @cargo_rule=CargoRule.where(:sitename=>sitename,:rulename=>rulename).first  
    raise if  @cargo_rule.blank?
    run_cargorule(rulename)
     @logger.info "#{Time.now} run #{sitename}-#{rulename} done "
    post_cargo_helper(sitename)    
     @logger.info "#{Time.now} post #{sitename}-#{rulename} done "
  end

end
