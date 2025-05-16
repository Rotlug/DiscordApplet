# DiscordApplet for Plasma

Displays the currently active members inside a specified discord server

## Dependencies

- `qtwebsockets`
- `python3` & `pip`

---

## How to Install

### 1. Clone the Repository

```bash
git clone https://github.com/Rotlug/DiscordApplet.git
cd DiscordApplet
```

### 2. Get Your Environment Variables

1. Create a `.env` file inside of the DiscordApplet folder
2. Go to [discord.com/developers/applications](https://discord.com/developers/applications) and make a new application
3. Inside your new application, enter the "Bot" tab and copy your token
4. Invite your new bot to the discord server you wish to monitor
5. In your discord app, go to `Settings > Advanced` and enable "Developer Mode"
6. Right-Click on the server you want to monitor, and copy it's ID.
7. Write the values you copied into the .env file like this

```
DISCORD_ACCESS_TOKEN=[Your Bot's Token]
GUILD_ID=[The Server Id You copied]
```

### 3. Install Python Dependencies

```bash
python3 -m pip install --user -r requirements.txt
```

### 4. Set Up systemd User Service

To run `main.py` automatically at user login, set up a systemd user service:

1. **Create the systemd user directory** (if it doesn't exist):

```bash
mkdir -p ~/.config/systemd/user
```

2. **Create the service file**:

```bash
nano ~/.config/systemd/user/discordapplet.service
```

Add the following content to the file:

```ini
[Unit]
Description=DiscordApplet Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 [Download Location]/main.py
Restart=on-failure
WorkingDirectory=[Download Location]

[Install]
WantedBy=default.target
```

3. **Reload systemd to recognize the new service**:

```bash
systemctl --user daemon-reload
```

4. **Enable the service to start at login**:

```bash
systemctl --user enable yourproject.service
```

5. **Start the service immediately**:

```bash
systemctl --user start yourproject.service
```

6. **Check the service status**:

```bash
systemctl --user status yourproject.service
```

### 5. Install the Plasma applet

To install the plasma applet to your system, copy the `com.github.rotlug.discordapplet` directory to `~/.local/share/plasma/plasmoids`.
