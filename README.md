# 🚀 Cloudflare Core Services Doom Demo

Welcome to the **Cloudflare Core Services Doom Demo**! This project showcases Cloudflare’s powerful core services by deploying a web-based Doom game on AWS Lightsail. Terraform provisions the infrastructure, Ansible configures the servers, and GitHub Actions automates deployment. Let’s dive into this high-performance, secure demo! 🎮

---

## 📋 Overview

This demo deploys:
- **Two AWS Lightsail instances** running Dockerized NGINX and Doom WebAssembly.
- **Cloudflare Core Services** for DNS, load balancing, WAF, SSL/TLS, and SSH protection.
- **Terraform** to manage infrastructure.
- **Ansible** to configure servers.
- **GitHub Actions** for seamless CI/CD.

The focus is on demonstrating Cloudflare’s Core Services, which provide robust security, performance, and connectivity for the Doom application and SSH access.

---

## 🌐 Cloudflare Core Services in Action

This project leverages Cloudflare’s Core Services to enhance security, performance, and reliability:

- **DNS Management** 📍: Cloudflare manages DNS records, creating dynamic subdomains for SSH (`<subdomain1>.<domain2>`, `<subdomain2>.<domain2>`) and the web app (`<subdomain3>.<domain2>`). CNAME and A records ensure seamless routing.
- **Load Balancing** ⚖️: A Cloudflare Load Balancer distributes traffic across the two Lightsail instances, using a health monitor to ensure high availability for the Doom web app.
- **Web Application Firewall (WAF)** 🛡️: Custom WAF rules protect the application by issuing managed challenges for suspicious paths (e.g., `/doom/`) and blocking requests from specific countries.
- **SSL/TLS Encryption** 🔒: Cloudflare issues an Origin CA certificate for secure HTTPS connections, with strict SSL settings and TLS 1.3 enabled for optimal security.
- **Spectrum for SSH** 🔗: Cloudflare Spectrum secures SSH access to the Lightsail instances over TCP/22, using dynamic edge IPs and direct traffic routing without proxying.

These services work together to deliver a secure, scalable, and performant demo, highlighting Cloudflare’s capabilities in a real-world application.

---

## 🛠️ Prerequisites

To get started, you’ll need:
- 🧰 **Terraform** (~1.0.0)
- 🛠️ **Ansible**
- ☁️ **AWS account** with Lightsail access
- 🌐 **Cloudflare account** with API token
- 🐙 **GitHub account** with a repository

---

## 🤖 Automated Deployment with GitHub Actions

The `.github/workflows/deploy.yml` workflow automates deployment on pushes to the `main` branch, showcasing Cloudflare’s integration in a CI/CD pipeline.

### Setup GitHub Secrets
Add these secrets in `Settings > Secrets and variables > Actions > Secrets`:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID

### What the Workflow Does
1. 📥 Checks out the code
2. 🧰 Sets up Terraform and AWS credentials
3. 🏗️ Runs Terraform to provision infrastructure, including Cloudflare resources
4. 📝 Updates `ansible/inventory.yml` with Terraform outputs
5. 🛠️ Runs Ansible to configure servers with Dockerized services

---

## 🚀 Quick Start: Local Deployment

Deploy the demo locally with these steps.

### 1. Clone the Repo
```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 2. Configure Terraform
Edit `infrastructure/terraform.tfvars` with your Cloudflare and domain details:
```hcl
domain1         = "vpn.example.com"
domain1_zone_id = "your-vpn-zone-id"
domain2         = "web.example.com"
domain2_zone_id = "your-web-zone-id"
account_id      = "your-cloudflare-account-id"
```

### 3. Provision Infrastructure
Run Terraform to set up AWS and Cloudflare resources:
```bash
cd infrastructure
terraform init
terraform apply
```
Approve the changes when prompted.

### 4. Save SSH Key
Store the SSH key for Ansible:
```bash
mkdir -p ../outputs
terraform output -raw aws-ssh-key > ../outputs/sshkey
chmod 600 ../outputs/sshkey
```

### 5. Update Ansible Inventory
Replace placeholders in `ansible/inventory.yml` with Terraform outputs:
- `{{ cloudflare_subdomain_1_ssh }}`: `terraform output -raw cloudflare-subdomain-1-ssh`
- `{{ cloudflare_subdomain_2_ssh }}`: `terraform output -raw cloudflare-subdomain-2-ssh`
- `{{ aws_server_username }}`: `terraform output -raw aws-server-username`
- `{{ cloudflare_subdomain_3_web }}`: `terraform output -raw cloudflare-subdomain-3-web`

Ensure `ansible_ssh_private_key_file: "../outputs/sshkey"`.

### 6. Configure Servers
Run the Ansible playbook to configure the servers with Docker and NGINX:
```bash
cd ..
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml --extra-vars "cloudflare_web_cert='$(terraform -chdir=infrastructure output -raw cloudflare-web-cert)' cloudflare_web_key='$(terraform -chdir=infrastructure output -raw cloudflare-web-key)'"
```

---

## 🌐 Accessing Your Deployment

Once deployed, access the demo:
- **SSH to VM1**:
  ```bash
  ssh -i outputs/sshkey <username>@<subdomain1>.<domain2>
  ```
- **SSH to VM2**:
  ```bash
  ssh -i outputs/sshkey <username>@<subdomain2>.<domain2>
  ```
- **Play Doom**:
  Visit `https://<subdomain3>.<domain2>/doom/` in your browser.

Get `<username>`, `<subdomain1>`, `<subdomain2>`, and `<subdomain3>` from Terraform outputs:
```bash
terraform -chdir=infrastructure output
```

---

## 🐞 Troubleshooting

- **Terraform fails?** Check AWS/Cloudflare credentials in `terraform.tfvars` or GitHub Secrets.
- **Ansible errors?** Verify SSH key permissions (`chmod 600 outputs/sshkey`) and network connectivity.
- **Cloudflare issues?** Ensure API token has permissions for DNS, WAF, Load Balancer, and Spectrum.
- **GitHub Actions stuck?** Check logs in the `Actions` tab.
- **Resources**: [Cloudflare Docs](https://developers.cloudflare.com/), [Terraform Docs](https://www.terraform.io/docs), [Ansible Docs](https://docs.ansible.com/).

---

## 👩‍💻 Contributing

Want to enhance this Cloudflare demo? Fork the repo, make changes, and submit a pull request. Issues and feature requests are welcome!

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

Enjoy exploring Cloudflare’s Core Services and fragging demons in Doom! 😈
