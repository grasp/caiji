# Load the rails application
require 'yaml'
YAML::ENGINE.yamler= 'syck'

require 'will_paginate/array'
#require 'will_paginate/array' #https://github.com/mislav/will_paginate/issues/163
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Caiji::Application.initialize!
