require "net/http"
require "uri"

wpdir = "/srv/www/wordpress/current"
dbname = node[:deploy][:wordpress][:database][:database]
dbuser = node[:deploy][:wordpress][:database][:username]
dbpass = node[:deploy][:wordpress][:database][:password]
dbhost = node[:deploy][:wordpress][:database][:host]
wp_admin_email = node[:deploy][:wordpress][:wp_admin_email]

execute "wp configure" do
   command "wp core config --dbname=#{dbname} --dbuser=#{dbuser} --dbpass=#{dbpass} --dbhost=#{dbhost}"
   cwd "#{wpdir}"
   user "deploy"
   not_if { File.exists?("#{wpdir}/wp-config.php") }
   action :run
end

public_hostname = "wjj-wp.ctcso.test-ccoa.technocuvic.com"

execute "db create" do
   command "wp db create"
   cwd "#{wpdir}"
   user "deploy"
   action :run
   ignore_failure true
end

execute "wp deploy" do
   command "wp core install --url=#{public_hostname} --title=Test --admin_name=admin --admin_password=admin --admin_email=#{wp_admin_email}"
   cwd "#{wpdir}"
   user "deploy"
   action :run
   not_if "sudo -u deploy wp core is-installed --path=#{wpdir}"
end

