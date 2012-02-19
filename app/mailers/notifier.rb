#coding:utf-8
class Notifier < ActionMailer::Base
  default :from => "w090.master@w090.com"
        
    def tuiguang_email(to) 
      @user=to
       @cargos=Cargo.skip(rand(Cargo.count-20)).limit(20)
       @trucks=Truck.skip(rand(Truck.count-20)).limit(20)
       title= $city_code_name[@cargos[0].fcity_code]+"到"+$city_code_name[@cargos[0].tcity_code]+ @cargos[0].cargo_weight || "0" +"吨/"+@cargos[0].cargo_bulk ||0+"方"
        mail(:to => to,
          :charset => "UTF-8",
          :from => "w090.master@w090.com",
          :subject => title)do |format|
             format.html{render "#{$project_root}/app/views/notifier/tuiguang_email"}
          end

    end
    

end