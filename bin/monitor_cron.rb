require 'rubygems' unless defined?(Gem)
require 'forever'
require 'logger'
logger=Logger.new("monitor.log")
Forever.run do
  dir File.expand_path('../', __FILE__) # Default is ../../__FILE__
    every 1.minutes do
    check_process=`ps -ef |grep cron`
 unless check_process.match(/cargo_cron\.rb/m)
`ruby /opt/vob/hunter/caiji/bin/cargo_cron.rb` #ugly hard code
 logger.info "try start cargo cron #{Time.now}"
end


 unless check_process.match(/truck_cron\.rb/m)
 `ruby /opt/vob/hunter/caiji/bin/truck_cron.rb`
logger.info "try start truck cron #{Time.now}"
end

unless check_process.match(/expire_cron\.rb/m)
`ruby /opt/vob/hunter/caiji/bin/expire_cron.rb`
logger.info "try start expire cron #{Time.now}"
end

  #  logger.info check_process
  end
  
  
    on_error do |e|
    puts "Boom raised: #{e.message} #{Time.now}"
  end

  on_exit do
    puts "Bye bye on #{Time.now}"
  end
end
