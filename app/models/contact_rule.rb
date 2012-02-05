class ContactRule
  include Mongoid::Document
  field :sitename, :type => String
  field :rulename, :type => String
  field :caiji_freq, :type => Integer
  field :need_post, :type => Boolean
  field :post_freq, :type => Integer
  field :fail_report, :type => Boolean
  field :report_email, :type => String
  field :report_phone, :type => String
  field :total_caiji, :type => Integer
  field :today_count, :type => Integer
  field :week_count, :type => Integer
  field :mongth_count, :type => Integer
  field :year_count, :type => Integer
  field :repeat_count, :type => Integer
  field :last_page,:type => Integer
  field :grasped_array,:type => String #for record province array
end
