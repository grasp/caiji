#coding:gb2312
require 'rubygems'  
require 'Win32Api'  

def send_sms(phone_number,message)

smsmode=Win32API.new("MonDem.dll","fnSetThreadMode",'L','L')  
puts "fnSetThreadMode return ="+smsmode.call(1).to_s

modemtype=Win32API.new("MonDem.dll","fnSetModemType",['L','L'],'L') 
puts "setmodemtype="+modemtype.call(2,0).to_s


sleep 2
puts "max support port="+Win32API.new("MonDem.dll","fnGetPortMax","" ,'L').call().to_s 
initmodem=Win32API.new("MonDem.dll","fnInitModem",'L','L') 
 puts "init return="+initmodem.call(-1).to_s
 
  sleep 2
#getstatus=Win32API.new("MonDem.dll","fnGetStatus",'L','L') 

 # puts "port 2 status before send="+getstatus.call(2).to_s

 # sleep 2
sendsms=Win32API.new("MonDem.dll","fnSendMsg",['L','P','P'],'L') 
puts "sendsms="+sendsms.call(-1,phone_number,message).to_s # we need wait up until send done

while true
readmsgx=Win32API.new("MonDem.dll","fnReadMsgEx",['L','P','P'],'L')
header=String.new
msgbox=String.new
result=readmsgx.call(-1,header,msgbox)
#puts "result=#{result}"
if result==0

#puts  header
# msgbox
break;
end
#puts "sleep 5 second to wait send finish"
sleep 5
end

clostmodem=Win32API.new("MonDem.dll","fnCloseModem",'L','L') 
  0.upto(7).each do |i|
  puts "port #{i}close status="+clostmodem.call(i).to_s
  end

  end

  #send_sms("15967126712","祝2012商祺！恭喜发财！")