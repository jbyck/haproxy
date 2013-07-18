# Return the port number to use for connection to the backend servers for the ACL
# If ACL has a member_port key with number fixnum, use that value, otherwise use global settings
#
# acl - Hash representing an ACL
#
# Returns fixnum
def acl_member_port(acl)
  return acl[:member_port] if acl.key?(:member_port) and acl[:member_port].kind_of?(Fixnum) 
  node[:haproxy][:member_port]
end

# Returns the max number of connections the ACL will accept
# If ACL has max_connections key with fixnum value, use that, otherwise use global settings
# 
# acl - Hash representing an ACL
#
# Returns fixnum
def acl_max_connections(acl)
  return acl[:max_connections] if acl.key?(:max_connections) and acl[:max_connections].kind_of?(Fixnum)
  node[:haproxy][:member_max_connections]
end

# Generate an HAProxy config safe ACL name from settings
# Strips non alpha charaters and lower cases
#
# acl - Hash representing an ACL
# 
# Returns string
def acl_name(acl)
  acl[:name].gsub(/[^A-Za-z0-9]/i, '').downcase
end

# Generates a name to use to identify backend servers, from the ACL 
#
# acl - The hash representing an ACL
#
# Returns string
def backend_acl_name(acl)
  "servers-#{acl_name(acl)}"
end

# Helper method for generated the server string to use when defining backend
#
# acl - The ACL as hash
# member - The member server as hash
#
# Returns string
def acl_server(acl, member)
  server = "server #{member[:hostname]} #{member[:ipaddress]}:#{acl_member_port(acl)} weight 1 maxconn #{acl_max_connections(acl)}"
  server = "#{server} check" if acl[:check]
  server
end
  
