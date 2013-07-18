Chef::Log.info "Create rsyslog template"

template "/etc/rsyslog.d/#{node[:haproxy][:log][:rsyslog]}" do
  owner     'root'
  group     'root'
  source    'rsyslog_haproxy.conf.erb'
  mode      644
  variables(:log => node[:haproxy][:log])
  notifies :restart, "service[rsyslog]"
end

Chef::Log.info "Create log rotation rules #{node[:haproxy][:log][:location]}"

logrotate_app "haproxy_log" do
  path      node[:haproxy][:log][:location]
  rotate    5
  frequency 'daily'
  size      '200M'
  options ['missingok', 'copytruncate', 'delaycompress', 'notifempty']
end

Chef::Log.info "Restarting rsyslog daemon"

service "rsyslog" do
  action :restart
end
