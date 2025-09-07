<img src="https://preview.redd.it/another-red-hat-bad-meme-v0-jpx322var48b1.jpg?width=640&crop=smart&auto=webp&s=3137295b740098915a494c15e214e9f6b6ffc680" width="400">

### Ansible playbooks for LNMP setup on Debian 12, a PoC

## README

This is a Proof of Concept on how to construct a secure and performant NGINX + MariaDB + PHP environment on Debian 12 (bookworm).

Playbook is created using Alibaba Cloud's default Debian 12.2 image (debian_12_2_x64_20G_alibase_20231012.vhd).

## Reliability

This playbook is not intended for "clone and play", although `main.yaml` should be runnable after you prepare all the configurations following the template, you should still read through the whole playbook first if you actually plan to run it on any production env.

## Key points

### 1-install.yaml

- MariaDB 11.4 (LTS) and the default stable PHP 8.2 version on Debian 12 (I opted not to go for the unstable distribution in order to get the current latest e.g. 8.2.12)
- Using BBR congestion control
- Using NGINX's official Ansible Role (Mainline by default)
- Unattended-Upgrade to keep the system up-to-date on patches

### 2-create-users.yaml

The idea is to only allow site user and nginx (R/O) access to the user's home directory, which also hosts the website root.

I understand that this might not the best possible design as we can further separate the website root from home directory, in that way, we should be able to achieve higher flexibility - make sure that nginx only gets R/O access, php-fpm user is created separately and gets R/W, then grant user the R/W access too.

But, I guess I just have this habit of doing things the /home/user/public_html way from the Virtualmin days. :)

Current design:

```
(/home)
drwx--x---  5 user1 user1 4.0K Nov  5 00:00 user1
(/home/user1)
drwxr-x---  5 user1 user1 4.0K Nov  5 00:00 public_html
(/home/user1/public_html)
-rw-r--r--  1 user1 user1 7.1K Nov  5 00:00 file
drwxr-xr--  9 user1 user1 4.0K Nov  5 00:00 folder
```

- nginx is added to the user1 group (so it has rx bit to folders, and r bit to files)
- Creating SSH keys for each users and not allowing password login of course

### 3-php-fpm.yaml

- Basically a lot of things referenced and learnt from the [OWASP PHP Configuration Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/PHP_Configuration_Cheat_Sheet.html)
- Since I favor TCP performance over unix socket, at the same time, I will need each process to be isolated so that it should only have access to that site's folder. In the end, I decided to have them listen on port `2+uid`, and run as those individual users for permission. Also adding `open_basedir` for a false sense of security. (i.e. `open_basedir` is never a promise, but still works. The best is of course to not grant access to anything besides the website root, as I mentioned in the previous section)

### 4-nginx.yaml

- Following [Mozilla's SSL best practices](https://ssl-config.mozilla.org/) (Modern)
- HTTP/2, all HTTP traffic is redirected to HTTPs, denies all traffic that doesn't properly uses SNI

***NOTE***  
[Testing OCSP Stapling](https://www.feistyduck.com/library/openssl-cookbook/online/testing-with-openssl/testing-ocsp-stapling.html)  

### 5-acme-sh.yaml

- Automate the installation and set up of acme.sh

***NOTE***  
The certificate generation step is using a DNS plugin, which likely does not fit others' environments. Do not choose to issue certificates immediately.

### 6-create-db.yaml

- Just the normal stuff. Creating individual databases and users, then activating the binary logs.

## Required settings

### secrets (folder)

Find templates for `secrets` under `secrets.renamethis`  
The most important one being the `users.yaml`

### settings.yaml

Find templates for `settings.yaml` in `settings.renamethis.yaml`

## Standalone playbooks

Find them under the `standalone_playbooks` folder, just some extra stuff like installing Google Cloud CLI, setting up wp-fail2ban, setting up server backup.

***NOTE***  
Standalone playbooks are not generic and you should never run them as it is.