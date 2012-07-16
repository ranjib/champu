require 'chef'
require 'mixlib/cli'
require 'mixlib/log'
require 'champu/version'
require 'champu/config'
require 'champu/step'

class Champu
  def initialize
  end
  def setup
    yield config
    Chef::Config.from_file(config[:knife_config_file])
  end
  def config
    @config ||= Champu::Config
  end
  def step(title)
    temp_step= Champu::Step.new(title)
    yield(temp_step)
    temp_step
  end
end
