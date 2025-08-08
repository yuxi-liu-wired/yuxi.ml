# yuxi.ml

Yuxi Liu's personal website.

## Deployment

This project uses a custom deployment script to manage the deployment of the website to the server. The script is located at `server_infra/remote_deploy.sh`.

To deploy the website:

1. `ssh` into the server.
2. Run `remote_deploy.sh`
3. `exit` the server.

The script does the following things:

- Pull repo.
- If `-n` is passed, it will copy nginx config files.
- If `-u` is passed, it will update itself.

To initialize the server, `curl` the deployment script:

```bash
curl -sSL https://raw.githubusercontent.com/yuxi-liu-wired/yuxi.ml/main/server_infra/remote_deploy.sh | bash
```