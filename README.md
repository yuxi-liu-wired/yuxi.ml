# yuxi.ml

Yuxi Liu's personal website.

## Deployment

### Initialize server machine

Get a test server locally.

```bash
docker run -d --name ubuntu-web -p 8082:80 ubuntu:24.04 sleep infinity

docker exec -it --user root ubuntu-web bash
apt-get update
apt-get upgrade -y
apt-get install -y unattended-upgrades apt-listchanges nginx curl git
yes | dpkg-reconfigure -plow unattended-upgrades
service nginx start
exit

lynx http://localhost:8082
```

### Initialize website

This project uses a custom deployment script to manage the deployment of the website to the server. The script is located at `server_infra/remote_deploy.sh`.

To deploy the website:

```bash
ssh 
chmod +x ~/remote_deploy.sh && ~/remote_deploy.sh
exit
```

To initialize the server, `curl` the deployment script:

```bash
curl -fsSL https://raw.githubusercontent.com/yuxi-liu-wired/yuxi.ml/main/server_infra/remote_deploy.sh | bash -s -- -i
```

