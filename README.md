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

To initialize the server, `curl` the deployment script:

```bash
curl -fsSL https://raw.githubusercontent.com/yuxi-liu-wired/yuxi.ml/main/server_infra/remote_deploy.sh | bash -s -- -i
```

Pushed updates to the GitHub repo will not automatically be pulled to the server. This is because the previous version had automatic deployment, which made me a bit self-conscious with pushing updates to the GitHub. This resulted in a few instances of almost lost work (and one instance of actually lost work). So now the server only updates when I choose to, independent of updates to the GitHub repo. This should help me feel safe to update as much as I please.

To deploy them to the public-facing website, `ssh` into the server and run

```bash
cd ~ && ./remote_deploy.sh
```

### Minimalism

Theoretically the Ubuntu is complete overkill. It would work just fine on a minimal server, such as BusyBox. It would just need `ssh`, `curl`, `tar`, `nginx`, and `openssl`. This requires some automation on the deployment to GitHub though to deploy the entire website as a single `tar` file, but that would require the annoying GitHub large files system.
