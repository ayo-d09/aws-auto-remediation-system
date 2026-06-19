<img width="1000" height="760" alt="architecture-diagram-2" src="https://github.com/user-attachments/assets/0f79a5fb-e4cd-4894-b933-1d0d7c6c20c3" />## AWS auto-remediation system

This is a monitoring and auto-healing system using a simple setup that watches your EC2 instance 24/7 and automatically fixes problems before you even notice using CloudWatch, Lambda, and Terraform.

## What It Does 

- Monitors CPU, Memory, Disk, and Network in real-time
- Sends warning emails when things get high (80%+)
- Automatically reboots the instance if it goes critical (90%+)
- Gives you a CloudWatch dashboard to check everything

  Fully managed with Terraform (deploy in minutes)
  
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
git clone https://github.com/ayo-d09/aws-auto-remediation-system.git
cd aws-auto-remediation-system
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

# SSH into the instance:

- Get the instance public ip using:
```bash
terraform output
```

- Find the .pem key: you need the key you used when creating the ec2 instance

- Fix key permissions:
```bash
chmod 400 ~/Downloads/yourpemkey.pem
```

- SSH into the instance:
ssh -i ~/Downloads/yourpemkey.pem ec2-user@<PUBLIC-IP>


# Generate high CPU load for 15 minutes:

Install stress-ng:

- Amazon Linux
```bash
sudo yum install -y epel-release && sudo yum install -y stress-ng
```
OR

- Ubuntu/Debian
```bash 
sudo apt install -y stress-ng
```
Then stress:
```bash
stress-ng --cpu $(nproc) --cpu-load 95 --timeout 0 &
```

For memory pressure:

```bash
stress-ng --vm 2 --vm-bytes 90% --vm-keep --timeout 0 &
```

Now wait around 10–15 minutes and:
- You’ll receive warning emails
- Then critical alerts
- The instance will reboot by itself
- Lambda will handle the recovery

You can watch the Lambda logs live with:
```bash
aws logs tail /aws/lambda/auto_heal_ec2 --follow
```
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
- **CriticalDisk-Autoheal**: Disk > 90% for 10 minutes → Reboots instance


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

Type "yes" when you get a prompt.

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

## License

MIT License - See LICENSE file for details

![Uploading architecture-diag<svg viewBox="0 0 1000 760" xmlns="http://www.w3.org/2000/svg" font-family="Arial, Helvetica, sans-serif">
  <defs>
    <marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L8,3 L0,6 Z" fill="#475569"/>
    </marker>
    <marker id="arrowRed" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L8,3 L0,6 Z" fill="#DC2626"/>
    </marker>
    <marker id="arrowAmber" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L8,3 L0,6 Z" fill="#D97706"/>
    </marker>
    <marker id="arrowPurple" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L8,3 L0,6 Z" fill="#7C3AED"/>
    </marker>
  </defs>

  <rect x="0" y="0" width="1000" height="760" fill="#ffffff"/>

  <text x="500" y="36" text-anchor="middle" font-size="24" font-weight="700" fill="#0f172a">AWS Auto-Remediation Architecture</text>
  <text x="500" y="58" text-anchor="middle" font-size="14" fill="#64748b">EC2 monitoring → CloudWatch alarms → automated recovery via Lambda</text>

  <!-- Terraform -->
  <rect x="20" y="90" width="200" height="55" rx="8" fill="#F3E8FF" stroke="#7C3AED" stroke-width="2"/>
  <text x="120" y="113" text-anchor="middle" font-size="14" font-weight="600" fill="#5B21B6">Terraform</text>
  <text x="120" y="131" text-anchor="middle" font-size="11" fill="#5B21B6">deploys &amp; manages all resources</text>

  <!-- EC2 -->
  <rect x="20" y="360" width="220" height="110" rx="8" fill="#DBEAFE" stroke="#2563EB" stroke-width="2"/>
  <text x="130" y="400" text-anchor="middle" font-size="15" font-weight="600" fill="#1E40AF">EC2 Instance</text>
  <text x="130" y="420" text-anchor="middle" font-size="12" fill="#1E40AF">+ CloudWatch Agent</text>
  <text x="130" y="440" text-anchor="middle" font-size="11" fill="#3B5BA9">(emits CPU/Mem/Disk/Net)</text>

  <!-- CloudWatch Metrics -->
  <rect x="330" y="360" width="220" height="110" rx="8" fill="#CCFBF1" stroke="#0D9488" stroke-width="2"/>
  <text x="440" y="400" text-anchor="middle" font-size="15" font-weight="600" fill="#0F766E">CloudWatch Metrics</text>
  <text x="440" y="420" text-anchor="middle" font-size="12" fill="#0F766E">CPU · Memory · Disk · Network</text>

  <!-- Dashboard -->
  <rect x="330" y="540" width="220" height="70" rx="8" fill="#CCFBF1" stroke="#0D9488" stroke-width="2"/>
  <text x="440" y="570" text-anchor="middle" font-size="14" font-weight="600" fill="#0F766E">CloudWatch Dashboard</text>
  <text x="440" y="588" text-anchor="middle" font-size="11" fill="#0F766E">visualization</text>

  <!-- Warning Alarm -->
  <rect x="640" y="200" width="190" height="70" rx="8" fill="#FEF3C7" stroke="#D97706" stroke-width="2"/>
  <text x="735" y="228" text-anchor="middle" font-size="14" font-weight="600" fill="#92400E">Warning Alarm</text>
  <text x="735" y="246" text-anchor="middle" font-size="11" fill="#92400E">&gt;80% for 10 min</text>

  <!-- Critical Alarm -->
  <rect x="640" y="470" width="190" height="70" rx="8" fill="#FEE2E2" stroke="#DC2626" stroke-width="2"/>
  <text x="735" y="498" text-anchor="middle" font-size="14" font-weight="600" fill="#991B1B">Critical Alarm</text>
  <text x="735" y="516" text-anchor="middle" font-size="11" fill="#991B1B">&gt;90% for 10 min</text>

  <!-- Email -->
  <rect x="860" y="90" width="120" height="55" rx="8" fill="#FEF3C7" stroke="#D97706" stroke-width="2"/>
  <text x="920" y="120" text-anchor="middle" font-size="13" font-weight="600" fill="#92400E">Alert Email</text>
  <text x="920" y="136" text-anchor="middle" font-size="10" fill="#92400E">via SNS</text>

  <!-- SNS -->
  <rect x="860" y="200" width="120" height="55" rx="8" fill="#FEF3C7" stroke="#D97706" stroke-width="2"/>
  <text x="920" y="232" text-anchor="middle" font-size="13" font-weight="600" fill="#92400E">SNS Topic</text>

  <!-- Lambda -->
  <rect x="860" y="470" width="120" height="70" rx="8" fill="#FEE2E2" stroke="#DC2626" stroke-width="2"/>
  <text x="920" y="498" text-anchor="middle" font-size="13" font-weight="600" fill="#991B1B">Lambda</text>
  <text x="920" y="514" text-anchor="middle" font-size="10" fill="#991B1B">auto_remediation.py</text>

  <!-- Arrows -->
  <line x1="120" y1="145" x2="130" y2="358" stroke="#7C3AED" stroke-width="2" stroke-dasharray="6,4" marker-end="url(#arrowPurple)"/>

  <line x1="240" y1="415" x2="328" y2="415" stroke="#475569" stroke-width="2" marker-end="url(#arrow)"/>
  <text x="284" y="405" text-anchor="middle" font-size="10" fill="#475569">metrics</text>

  <line x1="440" y1="470" x2="440" y2="538" stroke="#475569" stroke-width="2" marker-end="url(#arrow)"/>

  <path d="M550,390 C600,390 600,235 638,235" fill="none" stroke="#D97706" stroke-width="2" marker-end="url(#arrowAmber)"/>
  <path d="M550,440 C600,440 600,505 638,505" fill="none" stroke="#DC2626" stroke-width="2" marker-end="url(#arrowRed)"/>

  <line x1="830" y1="235" x2="858" y2="228" stroke="#D97706" stroke-width="2" marker-end="url(#arrowAmber)"/>
  <line x1="920" y1="200" x2="920" y2="147" stroke="#D97706" stroke-width="2" marker-end="url(#arrowAmber)"/>
  <line x1="830" y1="505" x2="858" y2="505" stroke="#DC2626" stroke-width="2" marker-end="url(#arrowRed)"/>

  <path d="M920,540 C920,660 130,660 130,469" fill="none" stroke="#DC2626" stroke-width="2.5" marker-end="url(#arrowRed)"/>
  <text x="525" y="678" text-anchor="middle" font-size="12" fill="#991B1B" font-weight="600">reboots instance (critical only)</text>

  <!-- Legend -->
  <rect x="20" y="700" width="14" height="14" fill="#FEF3C7" stroke="#D97706"/>
  <text x="40" y="711" font-size="11" fill="#475569">Warning path (notify)</text>
  <rect x="190" y="700" width="14" height="14" fill="#FEE2E2" stroke="#DC2626"/>
  <text x="210" y="711" font-size="11" fill="#475569">Critical path (auto-heal)</text>
  <rect x="380" y="700" width="14" height="14" fill="#F3E8FF" stroke="#7C3AED"/>
  <text x="400" y="711" font-size="11" fill="#475569">Infrastructure as Code</text>
</svg>
ram-2.svg…]()


## Author

Ayomide Obadina 
- GitHub: [@ayo-d09](https://github.com/ayo-d09)
- Linkedin: https://www.linkedin.com/in/ayomide-obadina-b2b7893b9
- Email: aobadina6@gmail.com
