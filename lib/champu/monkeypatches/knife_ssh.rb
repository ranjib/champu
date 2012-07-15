class Chef::Knife::Ssh
  def action_nodes(n)
    @action_nodes=n
  end
  def fix_longest(l)
    @longest=l 
  end
end
