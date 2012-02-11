def get_operator(mobilephone)
 yidong=[134,135,136,137,138,139,150,151,152,157,158,159,187,188,147]
liantong=[130,131,132,155,156,186,145]
dianxin=[133,153,189]
 yidong.each do |hao|
   if mobilephone.match(/#{hao}\d\d\d\d\d\d\d\d/)
     return 1
   end
 end
  liantong.each do |hao|
   if mobilephone.match(/#{hao}\d\d\d\d\d\d\d\d/)
     return 2
   end
 end
   dianxin.each do |hao|
   if mobilephone.match(/#{hao}\d\d\d\d\d\d\d\d/)
     return 3
   end
 end
 return 0
  
end