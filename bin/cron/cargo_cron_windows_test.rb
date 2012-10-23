#coding:utf-8

require 'pathname'
require 'forever'
pn = Pathname.new(File.dirname(__FILE__))
project_root=pn.parent.parent #do we have one line solution?
require File.join(project_root,"bin","cron","cron_init.rb")

class CronCargo
  include CargoRulesHelper
  include CargosHelper
  include CitiesHelper
#  include Qq56Helper
  
  def cargo_cron(sitename,rulename)
    cron_run_cargo_rule(sitename,rulename)
  end
end

 CronCargo.new.cargo_cron("tf56","tf56cargo")