node['mongodb']['nodename']  = "mongodb" 
node['mongodb']['isreplica'] = true
node['mongodb']['replSet']   = "mut8ed"
# node['mongodb']['bind_ip']   = '127.0.0.1'

package 'git'
package 'nginx'
package 'python-software-properties'
package 'curl'

include_recipe "apt"
include_recipe "nodejs::install_from_package"
include_recipe "mongodb-10gen::single"
include_recipe "rabbitmq"
include_recipe "redisio::install"
include_recipe "redisio::enable"

include_recipe "user"

user_account 'ryan' do
	ssh_keygen false
	ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMyNDl2Ncc9QkHPGYiJdqTPr70UnyEQq7nJ3ibLlRF8aZBekTJ/ZJnhPOU2tVdGuRp3vafJKxSzyFq7P2a+KQSnGDUA1Z5+hFNF0IzGsfpkd78qFW4AGkmeo+6bTt7jP2uDfogoAzm8YI/Vs11xCmajNWW1pOr2O0guEGcf/Zg81iQZYQAcI8vMcKrjwUi0KYYxtEL8VuB+bsSyudhU+OpFoNNtCRxB2kZ7jBaB5xmw8Oy/h0utm1CiUjQuLh/lQ+gTJcl6oAorUtRoZHGhJBnt3CkeCoiYaTWtODuanPXxatI6M+PsCkRgFBpGvRTBStRDNiAQv3S7raPqwUgNWFV Ryan wednesday@gmail.com']
end

user_account 'go' do
	ssh_keygen false
	ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMyNDl2Ncc9QkHPGYiJdqTPr70UnyEQq7nJ3ibLlRF8aZBekTJ/ZJnhPOU2tVdGuRp3vafJKxSzyFq7P2a+KQSnGDUA1Z5+hFNF0IzGsfpkd78qFW4AGkmeo+6bTt7jP2uDfogoAzm8YI/Vs11xCmajNWW1pOr2O0guEGcf/Zg81iQZYQAcI8vMcKrjwUi0KYYxtEL8VuB+bsSyudhU+OpFoNNtCRxB2kZ7jBaB5xmw8Oy/h0utm1CiUjQuLh/lQ+gTJcl6oAorUtRoZHGhJBnt3CkeCoiYaTWtODuanPXxatI6M+PsCkRgFBpGvRTBStRDNiAQv3S7raPqwUgNWFV Ryan wednesday@gmail.com']
end

template "/etc/sudoers" do
	source "sudoers.erb"
	mode 0440
	owner "root"
	group "root"
end

template '/etc/ssh/sshd_config' do
  source "sshdconfig.erb"
  owner "root"
  group "root"
  mode 00644
end

service 'ssh' do
	action :restart
end

service "nginx" do
	action :start
end

link "/etc/localtime" do
	to "/usr/share/zoneinfo/EST"
	notifies :restart, resources(:service => ["nginx"]), :delayed
	not_if "readlink /etc/localtime | grep -q 'EST$'"
end


## UFW ##

node['firewall']['rules'] = [
  "http" => {"port"=> "80"},
  "ssl" => {"port"=> "443"},
  "api" => {"port"=> "4000"}
]
include_recipe "ufw"

## nginx templates
template '/etc/nginx/sites-enabled/80' do
  source "nginx-80.erb"
  owner "root"
  group "root"
  mode 00644
end

template '/etc/nginx/sites-enabled/go' do
  source "nginx-go.erb"
  owner "root"
  group "root"
  mode 00644
end

cookbook_file '/etc/nginx/sites-enabled/default' do
	action :delete
end

execute "reload" do
  command "sudo service nginx reload"
end




