#coding:utf-8
require 'rubygems'
require 'pathname'
gem 'mechanize', '=2.0.1' #there have a exception stop us in version 2.1 ,have to work on this version
require 'mechanize'
require 'mongo'
require 'logger'
require 'mongoid'
#coding:utf-8
require "sqlite3"


#$debug=true 
#puts "debug mode=#{$debug}"
#connect to database
#$mongo=Mongo::Connection.new('localhost', 27017)
#$debug ? $db = $mongo.db('caiji_development') : $db = $mongo.db('caiji_production')
#$db = $mongo.db('caiji_development')  #always development database
#Mongoid.database = $db
Mongoid.database = Mongo::Connection.new('localhost', 27017).db('caiji_development') #first set as grasp
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?

#some sequence for load,otherwise load will fail as some file depends on others
require File.join(project_root,"config","initializers","init","city_dic.rb")
require File.join(project_root,"config","initializers","init","city_load.rb")
require File.join(project_root,"config","initializers","init","load_cookie.rb")

require File.join(project_root,"app","helpers","cities_helper.rb")
require File.join(project_root,"app","helpers","caiji_helper.rb")
require File.join(project_root,"app","helpers","cargos_helper.rb")
require File.join(project_root,"app","models","cargo.rb")
require File.join(project_root,"app","models","truck.rb")
require File.join(project_root,"app","models","cargo_rule.rb")
require File.join(project_root,"app","models","truck_rule.rb")

require File.join(project_root,"app","helpers","cargo_rules_helper.rb")
require File.join(project_root,"app","helpers","truck_rules_helper.rb")

require File.join(project_root,"bin","tuiguang","utility","check_operator.rb")



