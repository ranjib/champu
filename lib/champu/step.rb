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

    attr_reader :title,:config
    def nodes
      @nodes
    end
    
    def initialize(config,title)
      @title=title
      @config=config
      Chef::Config[:color]=true
    end
    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT,STDERR,STDIN,Champu::Config)
    end
    def search(term)
      Chef::Config[:knife][:ssh_attribute] = Champu::Config[:ssh_attribute]
      Chef::Config[:knife][:ssh_user]=Champu::Config[:ssh_user]
      @nodes=Chef::Search::Query.new.search(:node,term).first
    end
    def execute(command)
      ui.msg(ui.color("Executing command:",:magenta) + ui.color(command,:yellow))
      c=Chef::Knife::Ssh.new
      c.configure_attribute
      c.configure_user
      c.configure_identity_file
      c.config[:attribute]="ec2.public_ipv4"
      c.action_nodes(nodes)

      longest=0
      nodes.collect{|n|c.format_for_display(n)[c.config[:attribute]]}.each do |item|
        hostspec = "ec2-user@#{item}"
        session_opts = {}
        session_opts[:keys] = Champu::Config[:identity_file]
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
