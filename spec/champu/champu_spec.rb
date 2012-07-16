
require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require 'chef/knife/core/generic_presenter'
require 'chef/knife/core/node_presenter'
require 'chef/node'

describe Champu do
  let(:champu){Champu.new}
  describe "common to all steps" do

    it " should return config object" do
      champu.config.should be Champu::Config
    end

    it "should give setup method which accepts a block" do
      Chef::Config.stub(:from_file)
      expect {champu.setup}.to raise_error(LocalJumpError)
      expect {|b|champu.setup(&b)}.to yield_with_args(Champu::Config)
    end

    it "should allow user to set common config options" do
      Chef::Config.stub(:from_file)
      champu.setup do |config|
        config[:knife_config_file]='xx.rb'
      end
      champu.config[:knife_config_file].should == 'xx.rb'
    end

    it "should allow user to set step specific individual config option" do
        champu.step "check local config" do |step|
          step.config(:x=>1,:y=>2)
          step.config[:x].should == 1
          step.config[:y].should == 2
        end
    end

    it "should allow user to specify step specific ssh config as hash" do
      opts={:user=>'user',:identity_file=>'xx.pem'}
      step=Champu::Step.new("title") 
      step.config(opts)
      step.config.should  == opts
    end

    it "should allow user to set title for a step" do
      expect{ champu.step("test title")}.to raise_error(LocalJumpError)
      expect{|b| champu.step("test title",&b)}.to yield_with_args(Champu::Step)
      champu.step("test title"){|step|}.title.should == "test title"
    end

    it "should allow user to set search criteria for a step" do
      q=double('query')
      q.stub(:search).with(:node,"some criteria").and_return([[Chef::Node.new],1,1])
      Chef::Search::Query.stub(:new).with(no_args()).and_return(q)
      champu.step("test title") do |step|
        step.search("some criteria")
      end
    end

    it "should allow user to execute a command for a step" do
      q=double('query')
      n=Chef::Node.new
      n['att']= 'hosturl'
      q.stub(:search).with(:node,"some criteria").and_return([[n],1,1])
      Chef::Search::Query.stub(:new).with(no_args()).and_return(q)
      c=Chef::Knife::Ssh.new
      c.stub!(:ssh_command).with(kind_of(String))
      step=Champu::Step.new("title")
      step.stub!(:knife_ssh).and_return(c)
      step.config(:ssh_attribute =>'att',:ssh_user=>'testuser')
      step.search("some criteria")
      step.execute("some command")
    end

    it "should allow user to set the type of the step" do
      pending
    end
  end
  describe "parallel steps" do
  end
end
