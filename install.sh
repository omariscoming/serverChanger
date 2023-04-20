function changeserver(){
sudo apt-get install sshpass jq -y
read -p "OldServer: " OLDONE
read -p "NewServer: " NEWONE
read -p "Record Domain: " domain

ssh_command="
apt install curl
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh) -n
sudo apt update && sudo apt install nginx certbot python3-certbot-nginx -y
    cp /etc/nginx/sites-available/default /etc/nginx/sites-available/${domain}
    ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/
    sed -i \"s/_;/${domain};/\" \"/etc/nginx/sites-available/${domain}\"
    sed -i \"s/ default_server//\" \"/etc/nginx/sites-available/${domain}\"
    sed -i \"21 r /root/ReverseProxy_v2ray/reverse.txt\" \"/etc/nginx/sites-available/${domain}\"
    certbot --nginx --agree-tos --no-eff-email --redirect --expand --force-renewal -d ${domain} --register-unsafely-without-email
    systemctl restart nginx
"
ssh -o StrictHostKeyChecking=no "root@$NEWONE" "$ssh_command"
scp root@$OLDONE:/etc/x-ui/x-ui.db root@$NEWONE:/etc/x-ui/
x-ui restart
}

changeserver
