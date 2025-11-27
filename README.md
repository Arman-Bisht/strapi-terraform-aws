# Strapi CMS on AWS - Terraform Deployment

Deploy a fully functional Strapi Headless CMS on AWS using Infrastructure as Code (Terraform) with a single-instance architecture optimized for the AWS Free Tier.

## 🎯 Project Overview

This project demonstrates:
- **Infrastructure as Code** with Terraform
- **Automated deployment** of Strapi CMS
- **Cost optimization** using AWS Free Tier (t2.micro)
- **Memory optimization** using swap space to overcome t2.micro's 1GB RAM limitation
- **Security best practices** with auto-generated SSH keys and security groups
- **Process management** with PM2 for reliability

## 🏗️ Architecture

- **Provider**: AWS (us-east-1)
- **Compute**: EC2 t2.micro (Ubuntu 22.04 LTS)
- **Memory**: 1GB RAM + 2GB Swap Space
- **Database**: SQLite (local storage)
- **Networking**: VPC with Security Group (ports 22, 1337)
- **IP Management**: Elastic IP for consistent access
- **Access**: Auto-generated SSH key pair (4096-bit RSA)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with Free Tier eligibility

## Project Structure

```
.
├── provider.tf      # Terraform and provider configuration
├── variables.tf     # Input variables
├── main.tf          # Main infrastructure resources
├── outputs.tf       # Output values
├── install.sh       # User data script for Strapi installation
└── README.md        # This file
```

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 4. Access Strapi

After deployment (wait 5-10 minutes for installation):

- **Strapi URL**: Output will show `http://<public-ip>:1337`
- **Admin Panel**: `http://<public-ip>:1337/admin`

### 5. SSH Access

```bash
ssh -i strapi-key.pem ubuntu@<public-ip>
```

## Outputs

- `strapi_url`: Main Strapi endpoint
- `strapi_admin_url`: Admin panel URL
- `instance_public_ip`: EC2 public IP
- `ssh_command`: Ready-to-use SSH command
- `instance_id`: EC2 instance ID

## Monitoring Installation

SSH into the instance and check logs:

```bash
ssh -i strapi-key.pem ubuntu@<public-ip>
tail -f /var/log/strapi-install.log
```

Check PM2 status:

```bash
pm2 status
pm2 logs strapi
```

## Cost Considerations

This setup is **Free Tier eligible**:
- t2.micro instance (750 hours/month free)
- 8 GB EBS storage (30 GB free)
- Data transfer (15 GB free)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

## 🔑 Key Features

### Memory Optimization
Strapi requires 2GB RAM, but t2.micro only has 1GB. This project solves this by:
- Creating a 2GB swap file using disk space as virtual RAM
- Configuring optimal swappiness settings (vm.swappiness=10)
- Enabling persistent swap across reboots

### Automated Infrastructure
- Auto-generates 4096-bit RSA SSH key pair
- Creates and configures security groups
- Provisions Elastic IP for consistent access
- Installs and configures Node.js 20.x
- Sets up PM2 for process management
- Builds and deploys Strapi automatically

## 🔒 Security Notes

- SSH key is auto-generated and saved as `strapi-key.pem` (never committed to Git)
- Security group allows SSH (22) and Strapi (1337) from anywhere (0.0.0.0/0)
- **For production**: Restrict SSH access to specific IPs in the security group
- **Recommended**: Use HTTPS with a load balancer and SSL certificate
- **Best practice**: Enable AWS CloudWatch for monitoring and alerts

## Troubleshooting

If Strapi doesn't start:

1. Check installation logs: `tail -f /var/log/strapi-install.log`
2. Check PM2 status: `pm2 status`
3. Restart Strapi: `pm2 restart strapi`
4. Check security group rules in AWS console

## 📝 Important Notes

### Memory Management
The t2.micro instance has only 1GB RAM, but Strapi requires 2GB. The solution:
1. **Swap space** is created automatically during installation (2GB)
2. For **initial admin panel build**, you may need to temporarily upgrade to t3.small
3. After building, downgrade back to t2.micro - the built files remain and Strapi runs fine

### Building Admin Panel (if needed)
If the admin panel doesn't load:
```bash
# SSH into instance
ssh -i strapi-key.pem ubuntu@<public-ip>

# Navigate to project
cd /srv/strapi/my-project

# Build with increased memory
NODE_OPTIONS="--max-old-space-size=2048" npm run build

# Restart Strapi
pm2 restart strapi
```

## 🚀 Next Steps

- Set up first admin user at `/admin`
- Configure content types
- Create API endpoints
- Integrate with frontend application
- Set up automated backups
- Configure custom domain with Route 53
- Add SSL certificate with AWS Certificate Manager

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

Created as part of a DevOps assessment demonstrating Infrastructure as Code and cloud deployment skills.
