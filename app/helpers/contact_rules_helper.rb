#coding:utf-8
require 'open-uri'
require 'nokogiri'  
require 'zlib'
module ContactRulesHelper  
  #illegal character stoped page pase, we only get partial html , we have to refer open-uri to filter those illegal charater
  #we have to parse by ourself through raw html page
  def run_56135_contact_rule

    #totally 9189
    Encoding.default_internal="UTF-8"
    @page_count=get_last_page_number_of_contact("56135")
    @page_count.downto(1).each do |i|
          @all_raw_contact=Array.new
    mark_parsed_link=Array.new      
      response=String.new  
      puts "56135 start grasp page #{i}"
      begin
      open("http://www.56135.com/56135/company/companyindex/////#{i}.html",:proxy =>@proxy) {|f|          
        begin
          f.each_line {|line| response<<line}         
        rescue          
        end
      }
      rescue
        next
      end
      response.scan(/\/56135\/company\/member\/.\d\d\d+\.html/imx).each do |matched|
        one_contact=Hash.new
        company_link="http://www.56135.com"+matched.to_s          
        next if  mark_parsed_link.include?(company_link)
        #   @logger.info company_link
        mark_parsed_link<<company_link
        response2=String.new
        #still use ugly way    
        open(company_link,:proxy =>@proxy){|f|          
          begin
            f.each_line {|line| response2<<line}         
          rescue
          end
        }      
        # @logger.info response2
        #<span id="l_companyTitle">嘉美物流有限公司</span>        
        response2.scan(/\<span\sid=\"l_memberlink\"\>.*\<\/span\>/imx).each do |matched|
          # @logger.info  matched.to_s
          begin
            one_contact[:personname]=matched.to_s.match(/联系人：\W+\<br\>/o).to_s
            one_contact[:fixphone] = matched.to_s.match(/电话：\w+(\W)\w+\W/o).to_s
            one_contact[:mphone]= matched.to_s.match(/手机：\w+\W/o).to_s
            one_contact[:email] =  matched.to_s.match(/mailto:\w+\W\w+\.\w+\W/o).to_s
            begin
              one_contact[:personname].gsub("联系人：","").gsub(/\<br\>/,"").gsub(/\<br\>/,"").strip unless  one_contact[:personname].blank?
            rescue
            end
            one_contact[:fixphone] = one_contact[:fixphone].gsub("电话：","").gsub(/\</,"").gsub(/\W/,"") unless one_contact[:fixphone].blank? 
            one_contact[:mphone] = one_contact[:mphone].gsub("手机：","").gsub(/\</,"").gsub(/\W/,"") unless one_contact[:mphone].blank? 
            one_contact[:email] = one_contact[:email].gsub("mailto:","").gsub(/\>/,"").gsub(/\W$/,"") unless one_contact[:email].blank? 
          rescue
            #just continue
          end
          one_contact[:from_site]="56135"  
          @logger.info one_contact
          @all_raw_contact<< one_contact
          
          
        end
      end
      # puts   "start save contact"   
      save_contact
      @contact_rule.update_attribute(:last_page,i)
      puts   "56135 page #{i} done"
      @logger.info "page #{i} done"
    end

  end
  def run_tuge_contact_rule
   
    # (7..9).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    @contact_rule=ContactRule.where(:sitename=>"tuge").first
    #totally 3288
    @page_count=@contact_rule.last_page
    @page_count.downto(1).each do |i|
       @all_raw_contact=Array.new
      puts "tuge start grasp page #{i}"
      @mechanize.get("http://tuge.com/company/#{i}?companytype=alltype") do |page|
        #try test nokogiri(mechanize also ok) , is also ok,some mechanize only get partial html,really headeak, that why resort to nokogiri
        #   page =Nokogiri::HTML(open("http://tuge.com/company/#{i}?companytype=alltype",:proxy=>@proxy))
        #  @mechanize.open("http://tuge.com/company/#{i}?companytype=alltype") do |page|
        #    @logger.info "parse tuge page1"
  
        page.parser.css("div.title").each do |clink|
          company_link=clink.css("a").map { |link| link['href'] }            
          #  @logger.info company_link[0]
          unless company_link[0].nil?            
            detail_link=company_link[0].gsub("company_","elibrary/introduction_")
            #  @logger.info  detail_link
            @mechanizeb.get("http://www.tuge.com"+detail_link) do |page2|            
              one_contact=Hash.new
              one_contact[:companyname]=page2.parser.css("div.companyName")[0].content.strip
              @logger.info  one_contact[:companyname]
              section=page2.parser.css("div.content_detail")
              one_contact[:intro]=section[0].content
              #  @logger.info one_contact[:intro]
              contact_array=section[1].css("ul.contact li")
              one_contact[:personname]=contact_array[0].content.split("：")[1]
              one_contact[:fixphone]=contact_array[1].content.split("：")[1]
              one_contact[:mphone]=contact_array[2].content.split("：")[1]
              one_contact[:fax]=contact_array[3].content.split("：")[1]
              one_contact[:email]=contact_array[4].content.split("：")[1]
              one_contact[:address]=contact_array[4].content.split("：")[1]              
              other_info=section[1].css("td")
              one_contact[:companytype]=other_info[1].content
              one_contact[:registermoney]=other_info[5].content
              one_contact[:create_time]=other_info[7].content
              one_contact[:companyurl]=other_info[9].content   
              
              one_contact[:from_site]="tuge"  
              
              # @logger.info one_contact
              @all_raw_contact<< one_contact
            end
          end
        end
        @contact_rule.update_attribute(:last_page,i)
        save_contact
        puts "tuge  page #{i} done!"
      end
    end
  end
  
  def run_56885_contact_rule
    @all_raw_contact=Array.new
     
    @page_count=1
    @page_count.downto(1).each do |i|           
      #   page =Nokogiri::HTML(open("http://www.56885.net/yp_add_vlist.asp?id=52&page=#{i}",:proxy=>@proxy)) #still not work as mechaniz3
      #  @mechanize.user_agent_alias = 'Windows IE 6'
      Encoding.default_internal="UTF-8"
      html = Nokogiri::HTML(open("http://www.56885.net/yp_add_vlist.asp?id=52&page=#{i}",:proxy=>@proxy))      

      @logger.info html
      #   @mechanize.get("http://www.56885.net/yp_add_vlist.asp?id=52&page=#{i}") do |page|
      @logger.info "parse 56885 page1"
      @logger.info  html.to_html
      if false
        page.parser.xpath("/html/body/table[6]/tbody/tr/td[3]/table[2]/tbody/tr/td/p/a/strong").each do |tr |
          @logger.info tr.content
          unless company_link[0].nil?            
            detail_link=company_link[0].gsub("company_","elibrary/introduction_")
            #  @logger.info  detail_link
            @mechanizeb.get("http://www.tuge.com"+detail_link) do |page2|            
              one_contact=Hash.new
              one_contact[:companyname]=page2.parser.css("div.companyName")[0].content.strip
              @logger.info  one_contact[:companyname]
              section=page2.parser.css("div.content_detail")
              one_contact[:intro]=section[0].content
              #  @logger.info one_contact[:intro]
              contact_array=section[1].css("ul.contact li")
              one_contact[:personname]=contact_array[0].content.split("：")[1]
              one_contact[:fixphone]=contact_array[1].content.split("：")[1]
              one_contact[:mphone]=contact_array[2].content.split("：")[1]
              one_contact[:fax]=contact_array[3].content.split("：")[1]
              one_contact[:email]=contact_array[4].content.split("：")[1]
              one_contact[:address]=contact_array[4].content.split("：")[1]              
              other_info=section[1].css("td")
              one_contact[:companytype]=other_info[1].content
              one_contact[:registermoney]=other_info[5].content
              one_contact[:create_time]=other_info[7].content
              one_contact[:companyurl]=other_info[9].content                 
              one_contact[:from_site]="56885"                
              # @logger.info one_contact
              @all_raw_contact<< one_contact
              #  end
            end
          end
        end
      end
    end
    save_contact
  end

  def run_56110_contact_rule       
    @page_count=get_last_page_number_of_contact("56110")
    Encoding.default_internal="UTF-8"
    @page_count.downto(1).each do |i| 
      @all_raw_contact=Array.new 
      puts "56110 start page #{i}"
      page = @mechanize.get("http://www.56110.cn/company/list_p#{i}.html")
      page.parser().css("html body form#form1 table  tr td").each do |cargo_row|  
        cargo_link=cargo_row.css("a").map { |link| link['href'] }  
        cargo_link=cargo_link[0]       
        one_contact=Hash.new
        unless cargo_link.nil?
          if cargo_link.match(".56.56110.cn")    
            one_contact[:companyurl]=cargo_link
            #  @logger.info cargo_link
            page2 = @mechanizeb.get(cargo_link)
            contact=Array.new
            parsed_html=  page2.parser
            parsed_html.css("td.line_bottom").each do |item|
              contact<<item.content.strip
            end
            #get company name
            one_contact[:personname]=contact[0].to_s.strip unless contact[0].nil?
            one_contact[:fixphone]=contact[1].to_s.strip unless contact[1].nil?
            one_contact[:mphone]=contact[2].to_s.strip unless contact[2].nil?
            one_contact[:fax]=contact[3].to_s.strip unless contact[3].nil?
            one_contact[:QQ]=contact[4].to_s.strip unless contact[4].nil?
            one_contact[:email]=contact[6].to_s.strip unless contact[6].nil?
            one_contact[:address]=contact[7].to_s.strip unless contact[7].nil?
            one_contact[:from_site]="56110"
            parsed_html.css("#sitewhere div").each do |company|
              
              result= company.content.to_s.match(/：.* >/mu).to_s 
              one_contact[:company_name]= result.to_s.strip.gsub("：","").gsub(" >","").gsub(/\s/,"") unless result.nil?
            end
            parsed_html.css(".companyinfo p").each do |company|
              result=company.content
              one_contact[:intro]=result.to_s.strip unless result.nil?
            end         
            @all_raw_contact<< one_contact 
          elsif   cargo_link.match(/Company\/\d\d+\.html/)        
            cargo_link.match(/Company\/\d\d+\.html/).to_s.match(/\d+/)  
            contact_link="http://www.56110.cn/company/contact/"+cargo_link.match(/Company\/\d\d+\.html/).to_s.match(/\d+/).to_s+".html"
            page2 = @mechanizeb.get(contact_link)
            contact=Array.new
            parsed_html=  page2.parser
            parsed_html.css("table.mp_bj tr td").each do |item|
              contact<<item.content.strip            
            end
            one_contact[:personname]=contact[0].to_s.strip unless contact[0].nil?
            one_contact[:personname] << contact[1].to_s.strip unless contact[1].nil? #nil exception may happen ,haha
            one_contact[:mphone] = contact[2].match(/\d\d\d\d\d\d\d\d\d\d\d/).to_s unless contact[2].nil? #nil exception may happen ,haha
            one_contact[:fixphone] = contact[3] unless contact[3].nil? #nil exception may happen ,haha
            one_contact[:fixphone]=one_contact[:fixphone].gsub(/\(.*\)/,"") unless   one_contact[:fixphone].nil?
            one_contact[:fixphone]= one_contact[:fixphone].gsub(/电话：/mu,"")  unless one_contact[:fixphone].nil?
            one_contact[:QQ]=contact[4].to_s.strip  unless contact[4].nil?
            one_contact[:QQ]=one_contact[:QQ].gsub(/QQ：/mu,"") unless  one_contact[:QQ].nil?
            one_contact[:email]=contact[6].to_s.strip.gsub(/E-mail：/mu,"")  unless contact[6].nil?
            one_contact[:address]=contact[7].to_s.strip  unless contact[7].nil?
            one_contact[:from_site]="56110"                            
            @all_raw_contact<< one_contact 
  
          end
        end        
      end    
      puts "done on  page #{i}"
      save_contact   
      @contact_rule.update_attribute(:last_page,i)
    end
  end
  
  def run_zgdj_contact_rule   
 
     @page_count=get_last_page_number_of_contact("zgdj") 
    @page_count.downto(1).each do |i|    
      @all_raw_contact=Array.new    
      puts "zgdj start page #{i}"
      begin
      page = @mechanize.get("http://www.zgdj56.com/C/Contact.asp?id=#{i}")
      rescue
        next
      end
      one_contact=Hash.new
      contact=Array.new
      page.parser().css("html body table table table table tr td").each do |td|  
       contact<<td.content      
      end
      companyname= contact[0].gsub(/公司名称：/mu,"") unless contact[0].nil?
      companyname="" if companyname.nil?
      if (not companyname.nil?) && companyname.size>2
      one_contact[:companyname]=  companyname
      one_contact[:personname]= contact[1].gsub(/联系人：/mu,"") unless contact[1].nil?
       one_contact[:fixphone]= contact[2].gsub(/电话：/mu,"") unless contact[2].nil?
       one_contact[:mphone]= contact[3].gsub(/手机：/mu,"") unless contact[3].nil?
       unless one_contact[:fixphone].nil? #try guess mobile phone from fix 
       one_contact[:mphone]=one_contact[:fixphone].match(/\d\d\d\d\d\d\d\d\d\d\d/) if  one_contact[:mphone].nil? 
       end
       one_contact[:fax]= contact[4].gsub(/传真：/mu,"")  unless contact[4].nil?
       one_contact[:address]= contact[5].gsub(/地址：/mu,"").gsub(/邮编：/mu,"")  unless contact[5].nil?
       one_contact[:companyurl]= contact[6].gsub(/网址：/mu,"")  unless contact[6].nil?
       one_contact[:email]= contact[7].gsub(/E_mail：/mu,"")  unless contact[7].nil?
        one_contact[:from_site]= "zgdj"
         @all_raw_contact<< one_contact
      else
        next
      end
     # @logger.info contact
       puts "done on  page #{i}"
      save_contact   
      @contact_rule.update_attribute(:last_page,i)
     
    end
  end
  
  def  run_zgglwlw_contact_rule       
     @page_count=get_last_page_number_of_contact("zgglwlw") #26000
    # @page_count=499
       @page_count.downto(1).each do |i| 
       @all_raw_contact=Array.new 
      puts "zgglwlw start page #{i}"
      begin
      page = @mechanize.get("http://www.zgglwlw.com/index/companyweb/main.aspx?id=#{i}")
      rescue
        next
      end
      one_contact=Hash.new
      contact=Array.new
      page.parser().css("td.td2").each do |td|  
       contact<<td.content      
      end
     # contact.each_index do |index|
     #    @logger.info "index#{index}=#{contact[index]}"
    #  end
       one_contact[:personname]= contact[0].strip     unless contact[0].nil?
       one_contact[:mphone]= contact[1].strip unless contact[1].nil?
       one_contact[:fixphone]=contact[2].strip unless contact[2].nil?
       one_contact[:fax]=contact[3].strip unless contact[3].nil?
       one_contact[:email]=contact[4].strip unless contact[4].nil?
     
       intro_array=Array.new
       page.parser().css("div.jjmainbg").each do |intro|
       intro_array<<intro.content
       end
        one_contact[:intro]=intro_array[0] unless  intro_array[0].nil?
       one_contact[:from_site]="zgglwlw"       
       @all_raw_contact<<one_contact 
       puts "done on  page #{i}"
      save_contact   
      @contact_rule.update_attribute(:last_page,i)
     
  end
  end
  
  def run_yunli51_contact_rule 
  @page_count=get_last_page_number_of_contact("yunli51")  #just get @contact rule

  province_list={"110000"=>300,"120000"=>158,"130000"=>850,"140000"=>377,
                  "150000"=>344,"210000"=>429,"220000"=>202,"230000"=>344,"310000"=>516,"320000"=>827,
                  "330000"=>347, "340000"=>294,"350000"=>126,"360000"=>188,"370000"=>1195,
                   "410000"=>600, "420000"=>210,"430000"=>129,"440000"=>590,"450000"=>113,"460000"=>47,
                    "500000"=>45, "510000"=>220,"520000"=>17,"530000"=>63,"540000"=>8,
                  }
   left_province=Array.new               
  grasped_province= @contact_rule.grasped_array.split("#")    unless @contact_rule.grasped_array.nil?    
  all_province= province_list.keys  
  if grasped_province.nil?
  left_province=all_province
  else
    left_province=all_province-grasped_province
  end
  left_province.each do |province|
  # province_list.each do |province,total_page|
  total_page=province_list[province]
     total_page.downto(1).each do |i|
     page = @mechanize.get("http://www.51yunli.com/company/#{province}/#{i}/0/_0")
     puts "51yunli start #{province} page #{i}"
     raw_array=Array.new
     page.parser.css("p.b_newcolor").each do |line|     
      raw_array<<line
     end
      @all_raw_contact=Array.new
      raw_array.each_index do |index|        
        if index%3==0
          @one_contact=Hash.new
          raw_name_array=Array.new
          raw_array[index].css("span").each do |span|
           raw_name_array<< span.content
          end          
          @one_contact[:companyname]=raw_name_array[1]
          @one_contact[:address]=raw_name_array[2]
        end
        
        if index%3==1
           raw_name_array=Array.new
          raw_array[index].css("span").each do |span|
           raw_name_array<< span
          end
         # raw_name_array.each_index do |index|
         #   @logger.info "index#{index}=#{raw_name_array[index]}"
        #  end
        unless raw_name_array[1].content.nil?
         @one_contact[:mphone]=raw_name_array[1].content.match(/\d\d\d\d\d\d\d\d\d\d\d/).to_s
         @one_contact[:fixphone]=raw_name_array[1].content.match(/\d\d+-\d\d\d\d\d\d\d(\d)/).to_s
         @one_contact[:companytype]=raw_name_array[1].content.match(/\[.*\]/mu).to_s.gsub(/\[/,"").gsub(/\]/,"")
         @one_contact[:personname]=raw_name_array[1].content.match(/\s.*\[/mu).to_s.gsub(/\[/,"")
        end
        unless raw_name_array[2].to_s.nil?
          @one_contact[:QQ]=raw_name_array[2].to_s.match(/uin=\d\d\d\d\d+/).to_s
          @one_contact[:QQ]=@one_contact[:QQ].gsub("uin=","") unless @one_contact[:QQ].nil?
        end
        end
        if index%3==2
         @one_contact[:intro]=raw_array[index].content
          @one_contact[:from_site]="yunli51"
        # @logger.info   @one_contact
         @all_raw_contact<< @one_contact
        end      
      end
         save_contact
         puts "51yunli #{province} page #{i} done!"
     end
     #updated province as grasped
     @contact_rule.grasped_array="" if @contact_rule.grasped_array.nil?
     @contact_rule.update_attribute(:grasped_array,@contact_rule.grasped_array+"#"+province.to_s)
   
   end
     
  end
  
  def save_contact
    puts "save conact"
    @all_raw_contact.each do |contact|
      begin
        @logger.info "save conact #{contact}"   
        Contact.create!(contact)
        #   Contact.new(contact).save!
        
      rescue
        @logger.info "exception in save contact"
        @logger.info $@
      end
    end
  end
  
  def run_contactrule(rulename)
    prepare_for_rule("contactrule.log")
    case rulename    
    when "56135contact"
      run_56135_contact_rule  
    when "tugecontact"
      run_tuge_contact_rule
    when "56885contact"
      run_56885_contact_rule
    when "56110contact"
      run_56110_contact_rule
    when "zgdjcontact"
      run_zgdj_contact_rule
     when "zgglwlwcontact"
      run_zgglwlw_contact_rule
         when "yunli51contact"
      run_yunli51_contact_rule
    else
    end
  end
end
