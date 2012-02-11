 # coding: utf-8
class Tuiguang_Stats
   include Mongoid::Document
   include Mongoid::Timestamps 
     field :email_sent, :type=>Integer
     field :email_error, :type=>Integer
     field :sms_sent, :type=>Integer
     field :sms_error, :type=>Integer
end
