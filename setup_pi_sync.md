# Setting up Config Sync on Raspberry Pi

## Initial Setup (run once on Pi)

1. SSH into your Pi:
```bash
ssh pi@<your-pi-ip>
```

2. Navigate to config directory:
```bash
cd ~/printer_data/config
```

3. Initialize git (if not already done):
```bash
git init
git branch -M main
```

4. Add remote:
```bash
git remote add origin git@github.com:conrad760/VoronTridentSidepackConfig.git
```

5. Set up SSH key for GitHub (if not already done):
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Display the public key to add to GitHub
cat ~/.ssh/id_ed25519.pub
```
Add this key to GitHub: https://github.com/settings/keys

6. Configure git:
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

7. Initial sync:
```bash
# First, backup current config
cp -r ~/printer_data/config ~/printer_data/config.backup

# Pull from GitHub (this will get your latest changes)
git fetch origin
git pull origin main --allow-unrelated-histories

# If there are conflicts, resolve them, then:
git add .
git commit -m "Merge with GitHub repo"
git push origin main
```

8. Copy the sync script:
```bash
# Copy sync_config.sh to the Pi config directory
nano ~/printer_data/config/sync_config.sh
# Paste the content and save

# Make it executable
chmod +x ~/printer_data/config/sync_config.sh
```

## Daily Usage

### Push changes from Pi to GitHub:
```bash
cd ~/printer_data/config
./sync_config.sh push "Updated bed mesh"
```

### Pull changes from GitHub to Pi:
```bash
cd ~/printer_data/config
./sync_config.sh pull
```

### Sync (pull then push):
```bash
cd ~/printer_data/config
./sync_config.sh sync "Config updates"
```

### Check status:
```bash
cd ~/printer_data/config
./sync_config.sh status
```

## Optional: Auto-sync with systemd

Create a systemd service for automatic commits (optional):

1. Create service file:
```bash
sudo nano /etc/systemd/system/klipper-config-backup.service
```

2. Add content:
```ini
[Unit]
Description=Klipper Config Auto Backup
After=network.target

[Service]
Type=oneshot
User=pi
WorkingDirectory=/home/pi/printer_data/config
ExecStart=/home/pi/printer_data/config/autocommit.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

3. Create timer:
```bash
sudo nano /etc/systemd/system/klipper-config-backup.timer
```

4. Add content:
```ini
[Unit]
Description=Run Klipper Config Backup every 4 hours
Requires=klipper-config-backup.service

[Timer]
OnCalendar=0/4:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

5. Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable klipper-config-backup.timer
sudo systemctl start klipper-config-backup.timer
```

## Troubleshooting

- If you get permission errors, ensure the pi user owns the config directory:
  ```bash
  sudo chown -R pi:pi ~/printer_data/config
  ```

- If push fails, ensure your SSH key is added to GitHub

- For merge conflicts, edit the conflicted files, then:
  ```bash
  git add .
  git commit -m "Resolved conflicts"
  git push origin main
  ```