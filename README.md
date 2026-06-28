# Yamaha RT SIP Slack Logger

This repository provides a Lua script designed for YAMAHA routers to monitor SIP (Session Initiation Protocol) call events in syslog and send instant notifications to a Slack channel. It includes an automated generation and deployment script to streamline setup.

## Features
- **Real-Time Monitoring**: Continuously watches syslog for SIP call events (`[SIP] SIP Call from [sip:`).
- **Slack Alerts**: Sends formatted notifications to Slack using Incoming Webhooks.
- **Automated Deployment**: Generates the final Lua script with your Webhook URL and uploads it directly to the YAMAHA router via TFTP.

## Repository Structure
- [src/sip_logger.lua.tmpl](file:///d:/AntigravityWorkspace/yamahart-dispsip/src/sip_logger.lua.tmpl): The Lua template containing the syslog monitor logic and placeholder for the Slack Webhook.
- [deploy.sh](file:///d:/AntigravityWorkspace/yamahart-dispsip/deploy.sh): A shell script that populates the template and performs the TFTP upload to the router.
- [.env.example](file:///d:/AntigravityWorkspace/yamahart-dispsip/.env.example): Environment variable template for configuration.

## Getting Started

### Prerequisites
- A YAMAHA router supporting Lua script execution (e.g., RTX series).
- TFTP client command installed on the host machine.
- TFTP host access allowed on the router. Run the following command on your router to allow uploads from your PC:
  ```router
  tftp host <your-pc-ip>
  # Or to allow any host (use with caution)
  tftp host any
  ```

### Setup & Deployment

1. **Configure Environment Variables**
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   Open the `.env` file and set the required variables:
   - `ROUTER_IP`: The IP address of your YAMAHA router.
   - `SLACK_URL`: Your Slack Incoming Webhook URL.
   - `TARGET_FILENAME`: (Optional) The destination filename on the router's flash storage (defaults to `sip_logger.lua`).

2. **Run the Deployment Script**
   Execute the deploy script to replace the webhook placeholder and upload the script to the router:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

## YAMAHA Router Configuration

Once the script has been uploaded, configure the router to execute the Lua script in the background:

```router
# Run the uploaded Lua script
lua use 1 /sip_logger.lua

# (Optional) Verify that the script is running properly
show status lua
```