## Champu
Champu is a simple workflow/orchestration engine for chef-managed infrastructure

```ruby

    require 'champu'

    c=Champu.new

    c.setup do |config|
      config[:knife_config_file]= 'knife.rb'
      config[:identity_file] = 'private_key.pem'
      config[:ssh_user]      = 'user'
      config[:ssh_attribute]     = 'fqdn'
    end

    c.step "invoke yum update in all production servers" do |st|
      st.search("chef_environment:production")
      st.execute("sudo yum update")
    end

    c.setp "take on demand file system snapshot in all mysql servers" do |st|
      st.search("recipe:mysql")
      st.execute("sudo lvcreate -L10G -s -n dbsnapshot /dev/sda/mysql")
    end
```    

Champu uses Chef libraries to query server information and execute command via ssh into them.
Its dumb minimalist library aimed to facilitate readable infrastructure/deployment work flows.
Following dsl in champu:

```ruby
  step "step title" do |st|
    st.search "name:app-server-*"
    st.execute "service httpd restart"
  end
```
Is equivalent to:

```
  knife ssh "name:app-server-" "service httpd restart" 
```
