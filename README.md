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

sudo sh -c 'echo "<ip> yuxi-server" >> /etc/hosts'
ssh root@yuxi-server
cd ~ && ./remote_deploy.sh
```

### Minimalism

Theoretically the Ubuntu is complete overkill. It would work just fine on a minimal server, such as BusyBox. It would just need `ssh`, `curl`, `tar`, `nginx`, and `openssl`. This requires some automation on the deployment to GitHub though to deploy the entire website as a single `tar` file, but that would require the annoying GitHub large files system.

### SSL

Verify

```bash
openssl s_client -connect yuxi.ml:443 -servername yuxi.ml </dev/null -verify_return_error
```

#### DNS-01 challenge

The website uses SSL to secure the connection. The SSL certificate is generated using Let's Encrypt. The first certificate was generated using the DNS-01 challenge to avoid breaking production while testing the deployment script. The certificate is renewed automatically every 90 days using the `certbot` package.

```bash
sudo certbot certonly --manual --preferred-challenges dns -d yuxi.ml  -d *.yuxi.ml --agree-tos -m yuxi@yuxi.ml --no-eff-email

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for *.yuxi.ml

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name:

_acme-challenge.yuxi.ml.

with the following value:

<your DNS TXT record here>

Before continuing, verify the TXT record has been deployed. Depending on the DNS
provider, this may take some time, from a few seconds to multiple minutes. You can
check if it has finished deploying with aid of online tools, such as the Google
Admin Toolbox: https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.yuxi.ml.
Look for one or more bolded line(s) below the line ';ANSWER'. It should show the
value(s) you've just added.
```

After following the instructions to add the DNS TXT record, I waited for a few minutes for the DNS record to propagate. I then verified the DNS TXT record using `dig`:

```bash
dig TXT _acme-challenge.yuxi.ml @ns1.dyna-ns.net

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> TXT _acme-challenge.yuxi.ml @ns1.dyna-ns.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 45039
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;_acme-challenge.yuxi.ml.       IN      TXT

;; ANSWER SECTION:
_acme-challenge.yuxi.ml. 300    IN      TXT     "<DNS TXT record here>"

;; Query time: 37 msec
;; SERVER: 162.159.27.158#53(ns1.dyna-ns.net) (UDP)
;; WHEN: Sat Aug 09 14:32:54 PDT 2025
;; MSG SIZE  rcvd: 108
```

then I just pressed Enter to continue.

```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/yuxi.ml/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/yuxi.ml/privkey.pem
This certificate expires on 2025-11-07.
These files will be updated when the certificate renews.

NEXT STEPS:
- This certificate will not be renewed automatically. Autorenewal of --manual certificates requires the use of an authentication hook script (--manual-auth-hook) but one was not provided. To renew this certificate, repeat this same certbot command before the certificate's expiry date.
```

The certificate is stored in `/etc/letsencrypt/live/yuxi.ml/`. The private key is stored in `/etc/letsencrypt/live/yuxi.ml/private.key`. This then needs to be copied to the Nginx configuration directory, which is `/etc/nginx/ssl/`. The Nginx configuration file is located at `/etc/nginx/sites-available/default`.

```bash
sudo cp /etc/letsencrypt/live/yuxi.ml/fullchain.pem /tmp/yuxi.ml.crt
sudo cp /etc/letsencrypt/live/yuxi.ml/privkey.pem /tmp/yuxi.ml.key
sudo chown $USER:$USER /tmp/yuxi.ml.crt
sudo chown $USER:$USER /tmp/yuxi.ml.key
scp /tmp/yuxi.ml.crt root@yuxi-server:/etc/nginx/ssl/yuxi.ml.crt
scp /tmp/yuxi.ml.key root@yuxi-server:/etc/nginx/ssl/yuxi.ml.key
rm /tmp/yuxi.ml.crt
rm /tmp/yuxi.ml.key
```

#### HTTP-01 challenge

After struggling with the SSL certificate for a while, I realized that Dynadot sucks at DNS propagation, so I just installed acme.sh on the server and used that to generate the SSL certificate. This is much easier and more reliable. Just run `server_infra/initialize_acme.sh` to generate the SSL certificate using the HTTP-01 challenge. It will automatically configure Nginx to serve the challenge file and renew the certificate every 60 days.

#### Self-signed

There is also self-signed SSL certificate for local development. It is generated using the `openssl` command:

```bash
openssl req -new -newkey rsa:2048 -nodes -keyout localhost.key -out localhost.csr
```
