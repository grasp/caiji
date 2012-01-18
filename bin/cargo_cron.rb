#coding:utf-8

require "./cron_init.rb"

class CronCargo
  include CargoRulesHelper
  include CargosHelper
  include CitiesHelper
  include Qq56Helper
  
  def cargo_cron(sitename,rulename)
    cron_run_cargo_rule(sitename,rulename)
  end
end


start=Time.now
#CronCargo.new.cargo_cron("tf56","tf56cargo")
#CronCargo.new.cargo_cron("56qq","56qqcargo")
#CronCargo.new.cargo_cron("56135","56135cargo")
#CronCargo.new.cargo_cron("quzhou","quzhoucargo")
CronCargo.new.cargo_cron("haoyun56","haoyuncargo")
puts "cost time=#{Time.now-start}"




