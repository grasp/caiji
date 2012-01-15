class CargoRule
  include Mongoid::Document
  field :sitename, :type => String
  field :rulename, :type => String
  field :nextpage, :type => Array
  field :mainurl, :type => String
  field :suburl, :type => String
  field :maincss, :type => String
  field :subcss, :type => String  
  field :caiji_freq, :type => Integer
  field :need_post, :type => Boolean
  field :post_freq, :type => Integer
  field :fail_report, :type => Boolean
  field :report_email, :type => String
  field :report_phone, :type => String
  field :fcity_name, :type => Array
  field :tcity_name, :type => Array
  field :cargo_weight, :type => Array
  field :cargo_bulk, :type => Array
  field :cate_name, :type => Array
  field :mobilephone, :type => Array
  field :fixphone, :type => Array
  field :contact, :type => Array
  field :company, :type => Array
  field :comments, :type => Array
  field :timetag, :type => Array
  field :total_caiji, :type => Integer
  field :today_count, :type => Integer
  field :week_count, :type => Integer
  field :mongth_count, :type => Integer
  field :year_count, :type => Integer
  field :repeat_count, :type => Integer
end
