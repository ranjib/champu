require 'mixlib/config'
class Champu
  class Config
    extend Mixlib::Config

    knife_config_file  '.chef/knife.rb'
    color true
  end
end


