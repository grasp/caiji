#coding:utf-8
require 'open-uri'
require 'nokogiri'  
module ContactRulesHelper
  
  #illegal character stoped page pase, we only get partial html , we have to refer open-uri to filter those illegal charater
  #we have to parse by ourself through raw html page
  def run_56135_contact_rule
    @all_raw_contact=Array.new
    mark_parsed_link=Array.new
    # (7..9).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count=1
    @page_count.downto(1).each do |i|
      response=String.new  
 
      open("http://www.56135.com/56135/company/companyindex/////#{i}.html") {|f|          
        begin
          f.each_line {|line| response<<line}         
        rescue
        end
      }
      response.scan(/\/56135\/company\/member\/.\d\d\d+\.html/imx).each do |matched|
       one_contact=Hash.new
       company_link="http://www.56135.com"+matched.to_s          
             next if  mark_parsed_link.include?(company_link)
               @logger.info company_link
        mark_parsed_link<<company_link
       response2=String.new
       #still use ugly way    
     open(company_link){|f|          
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
          #   @logger.info one_contact
             @all_raw_contact<< one_contact
        end
      end
      end
    save_contact
  end
  def run_tuge_contact_rule
    @all_raw_contact=Array.new
    # (7..9).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count=1
    @page_count.downto(1).each do |i|
      @mechanize.get("http://tuge.com/company/#{i}?companytype=alltype") do |page|
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
      end
    end
    save_contact
  end
  
  def run_56885_contact_rule
    @all_raw_contact=Array.new
    # (7..9).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    # `set http_proxy=wwwgate0-ch.mot.com:1080`
    
  
    @page_count=1
    @page_count.downto(1).each do |i|
           
      @mechanize.get("http://www.56885.net/yp_add_vlist.asp?id=52&page=#{i}") do |page|
        @logger.info "parse 56885 page1"
        #  @logger.info  page.parser.css("table tr td p a strong")[2].text
        @logger.info  page.parser.to_html
        if false
          page.parser.xpath("/html/body/table[6]/tbody/tr/td[3]/table[2]/tbody/tr/td/p/a/strong").each do |tr |
            @logger.info tr.content
            # company_link=tr.css("td a").map { |link| link['href'] }
            # @logger.info company_link          
       
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
              
                one_contact[:from_site]="56885"  
              
                # @logger.info one_contact
                @all_raw_contact<< one_contact
              end
            end
          end
        end
      end
    end
      save_contact
  end


  def save_contact
     @all_raw_contact.each do |contact|
      begin
        Contact.new(contact).save!
      rescue
        @logger.info "exception in save contact"
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

    else
    end
  end
end
