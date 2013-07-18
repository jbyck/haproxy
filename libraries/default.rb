def defaults_options
  options = node.default['haproxy']['defaults_options']
  if node['haproxy']['x_forwarded_for']
    options.push("forwardfor")
  end
  return options.uniq
end

def defaults_timeouts
  node['haproxy']['defaults_timeouts']
end

def global_log_line
  "#{node[:haproxy][:log][:host]} #{node[:haproxy][:log][:facility]} #{node[:haproxy][:log][:level]}"
end

def member_search(role)
  search("node", "role:#{role} AND chef_environment:#{node.chef_environment}") || []
end

def server_ip_from_member(member)
  begin
    if member.attribute?('cloud')
      if node.attribute?('cloud') && (member['cloud']['provider'] == node['cloud']['provider'])
         member['cloud']['local_ipv4']
      else
        member['cloud']['public_ipv4']
      end
    else
      member['ipaddress']
    end
  end
end

def member_data(member)
  {:ipaddress => server_ip_from_member(member), :hostname => member['hostname']}
end

