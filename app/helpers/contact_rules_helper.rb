module ContactRulesHelper
  
  def run_56135_contact_rule
    @all_raw_contact=Array.new
    # (7..9).include?(Time.now.hour) ? @page_count=3 : @page_count=1  #in busy time ,we need fetch more page  
    @page_count=1
    @page_count.downto(1).each do |i|
     @mechanize.get("http://www.56135.com/56135/company/companyindex/////#{i}.html") do |page|
      page.parser.css("div.c_name").each do |clink|
       company_link=clink.css("a").map { |link| link['href'] } 
     @logger.info "http://www.56135.com"+company_link[0]
          @mechanizeb.get("http://www.56135.com"+company_link[0]) do |page2|
              @logger.info "parse page2"
          #  page2.parser.css("div.contact_info_1").each do |contact1|
          #    @logger.info contact1.content
            @logger.info  page2.parser.xpath("//div[@class='contact_info_1']").to_html
           end
           end
          end
      end
      end


  def save_contact
    
  end
  
  def run_contactrule(rulename)
    prepare_for_rule("contactrule.log")
    case rulename    
    when "56135contact"
      run_56135_contact_rule

    else
    end
  end
end
