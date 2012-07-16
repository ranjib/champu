require 'chef'
require 'chef/knife/ssh'
require 'net/ssh'
require 'net/ssh/multi'
require 'readline'
require 'chef/search/query'
require 'chef/mixin/command'
require 'champu/monkeypatches/knife_ssh'

class Champu
  class Step

    attr_reader :title

    def initialize(title)
      @title=title
      Chef::Config[:color]=true
      @config={}
    end

    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT,STDERR,STDIN,Champu::Config)
    end

    def nodes
      @nodes
    end

    def config(opts={})
      @config.merge!(opts) unless opts.empty?
      @config
    end
  
    def config_value(key)
      @config.key?(key) ? @config[key] : Champu::Config[key]
    end

    def search(term)
      Chef::Config[:knife][:ssh_attribute] = config_value(:ssh_attribute)
      Chef::Config[:knife][:ssh_user]= config_value :ssh_user
      @nodes=Chef::Search::Query.new.search(:node,term).first
    end

    def knife_ssh
     @knife_ssh ||= Chef::Knife::Ssh.new
    end

    def execute(command)
      Chef::Config[:knife][:ssh_attribute] = config_value :ssh_attribute
      Chef::Config[:knife][:ssh_user]= config_value :ssh_user
      ui.msg(ui.color("Executing command:",:magenta) + ui.color(command,:yellow))
      c=knife_ssh
      c.configure_attribute
      c.configure_user
      c.configure_identity_file
      c.config[:attribute]= config_value :ssh_attribute
      c.action_nodes(nodes)

      longest=0
      nodes.each do  |n|
        p_node= c.format_for_display(n)
        item=p_node[c.config[:attribute]]
        hostspec = "#{config_value(:ssh_user)}@#{item}"
        session_opts = {}
        session_opts[:keys] = config_value :identity_file
        session_opts[:keys_only] = true 
        session_opts[:logger] = Chef::Log.logger 
        session_opts[:paranoid] = false
        session_opts[:user_known_hosts_file] = "/dev/null"
        c.session.use(hostspec, session_opts)
        longest = item.length if item.length > longest
      end
      c.fix_longest(longest)
      c.ssh_command(command)
      c.session.close
    end
  end
end
