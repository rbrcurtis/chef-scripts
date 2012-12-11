node['mongodb']['nodename']  = "mongodb" 
node['mongodb']['isreplica'] = true
node['mongodb']['replSet']   = "mut8ed"

package 'git'
package 'nginx'

include_recipe "apt"
include_recipe "nodejs::install_from_package"
include_recipe "mongodb-10gen::single"

include_recipe "user"

user_account 'ryan' do
	ssh_keygen false
	ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMyNDl2Ncc9QkHPGYiJdqTPr70UnyEQq7nJ3ibLlRF8aZBekTJ/ZJnhPOU2tVdGuRp3vafJKxSzyFq7P2a+KQSnGDUA1Z5+hFNF0IzGsfpkd78qFW4AGkmeo+6bTt7jP2uDfogoAzm8YI/Vs11xCmajNWW1pOr2O0guEGcf/Zg81iQZYQAcI8vMcKrjwUi0KYYxtEL8VuB+bsSyudhU+OpFoNNtCRxB2kZ7jBaB5xmw8Oy/h0utm1CiUjQuLh/lQ+gTJcl6oAorUtRoZHGhJBnt3CkeCoiYaTWtODuanPXxatI6M+PsCkRgFBpGvRTBStRDNiAQv3S7raPqwUgNWFV Ryan wednesday@gmail.com']
end

template "/etc/sudoers" do
	source "sudoers.erb"
	mode 0440
	owner "root"
	group "root"
end

service "sysklogd"
service "nginx"

link "/etc/localtime" do
	to "/usr/share/zoneinfo/EST"
	notifies :restart, resources(:service => ["sysklogd", "nginx"]), :delayed
	not_if "readlink /etc/localtime | grep -q 'EST$'"
end
