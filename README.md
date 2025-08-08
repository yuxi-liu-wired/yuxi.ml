# yuxi.ml

Yuxi Liu's personal website.

## Deployment

This project uses a custom deployment script to manage the deployment of the website to the server. The script is located at `server_infra/remote_deploy.sh`.

To deploy the website:

```bash
ssh 
~/remote_deploy.sh
exit
```

To initialize the server, `curl` the deployment script:

```bash
curl -fsSL https://raw.githubusercontent.com/yuxi-liu-wired/yuxi.ml/main/server_infra/remote_deploy.sh | bash -s -- -i
```
