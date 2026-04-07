# AWS Monitoring & Auto-Healing System

A simple setup that watches your EC2 instance 24/7 and automatically fixes problems before you even notice using CloudWatch, Lambda, and Terraform.

## What It Does 

- Monitors CPU, Memory, Disk, and Network in real-time
- Sends warning emails when things get high (80%+)
- Automatically reboots the instance if it goes critical (90%+)
- Gives you a CloudWatch dashboard to check everything
- Fully managed with Terraform (deploy in minutes)
  
## Features

- Real-time monitoring of CPU, Memory, Disk, and Network metrics
- Multi-level alerting (Warning at 80%, Critical at 90%)
- Automated instance recovery via Lambda
- Email notifications
- Infrastructure as Code using Terraform
- CloudWatch Dashboard for visualization

## Architecture

See (ARCHITECTURE.md) for detailed system design.

## Prerequisites

- AWS Account with the right permissions
- Terraform
- AWS CLI configured
- SSH key pair for EC2 access

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/aws-monitoring-automation.git
cd aws-monitoring-automation
```

### 2. Configure Variables
Edit `terraform.tfvars`:
```hcl
alert_email = "your-email@example.com"
```

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. Confirm SNS Subscription (Email)

Check your email and confirm the SNS subscription to receive alerts.

### 5. Access Dashboard

After deployment, Terraform outputs the CloudWatch Dashboard URL.

## How to Test Auto-Healing 

SSH into the instance and stress the CPU:

# Generate high CPU load for 15 minutes
timeout 900 dd if=/dev/zero of=/dev/null &
timeout 900 dd if=/dev/zero of=/dev/null &

Now wait around 10–15 minutes and:
- You’ll receive warning emails
- Then critical alerts
- The instance will reboot by itself
- Lambda will handle the recovery

You can watch the Lambda logs live with:
aws logs tail /aws/lambda/auto_heal_ec2 --follow

## Project Structure
```
aws-monitoring-automation/
├── main.tf                # Provider and EC2 instance
├── alarm.tf               # CloudWatch alarms (warning level)
├── auto_healing.tf        # Lambda and critical alarms
├── dashboard.tf           # CloudWatch dashboard
├── variables.tf           # Input variables
├── terraform.tfvars       # Variable values
├── lambda/
│   └── auto_remediation.py  # Auto-healing Lambda function
├── ARCHITECTURE.md       # System architecture
└── README.md             # This file
```

## Monitoring Metrics

### AWS Native Metrics
- CPU Utilization
- Network In/Out
- Disk Read/Write Operations

### CloudWatch Agent Metrics
- Memory Usage Percentage
- Disk Usage Percentage
- CPU Usage (Active/Idle breakdown)

## Alarm Configuration

### Warning Alarms (Notification Only)
- **HighCPUUtilization**: CPU > 80% for 10 minutes
- **high-memory**: Memory > 80% for 10 minutes
- **high-disk-usage**: Disk > 80% for 10 minutes

### Critical Alarms (Auto-Healing)
- **CriticalCPU-AutoHeal**: CPU > 90% for 10 minutes → Reboots instance
- **CriticalMemory-AutoHeal**: Memory > 90% for 10 minutes → Reboots instance


## Cost Estimate

Approximate monthly costs (us-east-1):
- EC2 t3.micro: ~$7.50
- CloudWatch metrics: ~$3.00
- CloudWatch alarms: ~$1.00
- Lambda executions: <$0.20
- SNS notifications: <$0.50

**Total: ~$12/month**

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

Type "yes" when prompted.

## Security Considerations

- Lambda has minimal IAM permissions (only reboot instances)
- SNS topics are private
- CloudWatch logs retained for 30 days
- No hardcoded credentials

## Possible Improvements

- Add auto-scaling based on metrics
- Implement instance replacement instead of reboot
- Add Slack/PagerDuty integration
- Multi-region support
- Add database monitoring
- Custom metric collection

## Troubleshooting

### CloudWatch Agent Not Running
```bash
sudo systemctl status amazon-cloudwatch-agent
sudo systemctl restart amazon-cloudwatch-agent
```

### Metrics Not Appearing

- Verify IAM role attached to EC2 instance
- Check CloudWatch Agent logs: `/opt/aws/amazon-cloudwatch-agent/logs/`
- Ensure security group allows outbound HTTPS

### Lambda Not Triggering

- Check SNS topic subscription
- Verify Lambda execution role permissions
- Review CloudWatch Logs for errors

## Contributing

Please open an issue or submit a pull request.
...looking forward 

## License

MIT License - See LICENSE file for details

## Author

Ayomide Obadina 
- GitHub: [@ayo-d09](https://github.com/ayo-d09)
- Linkedin: https://www.linkedin.com/in/ayomide-obadina-b2b7893b9
- Email: ddraven009@gmail.com
