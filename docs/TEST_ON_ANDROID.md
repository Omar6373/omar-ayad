# How to test Omar RP from Android

## 1. Verify GitHub source
Open https://github.com/Omar6373/omar-ayad and select **Actions**.
The **Pawn source checks** workflow validates file presence and a few static invariants. Green is NOT proof that Pawn compiled.

## 2. Prepare an open.mp host
Use a Linux VPS or local Linux PC with UDP 7777 reachable from your phone.
Install the current open.mp server release, Pawn compiler, matching open.mp includes, a compatible MySQL plugin and a compatible bcrypt plugin. Pin plugin versions and confirm their APIs before compiling.
Install MariaDB; create a restricted database user and execute database/schema.sql.
Copy config.json to the server directory. Set unique RCON credentials and actual database credentials via private server configuration. Never commit secrets.
Compile gamemodes/omarrp.pwn to gamemodes/omarrp.amx. Resolve all compiler errors first.
Start open.mp and inspect console logs for database connection and gamemode startup.

## 3. Join from the phone
Install a ReSA Android client from a source you trust. Confirm its SA-MP/open.mp compatibility and required game assets.
Add the VPS public IPv4 and port 7777 to the client.
Register, reconnect and log in, respawn, check /balance and /district.
Use a second account to test concurrency and duplicate registration.
If connection fails, check UDP firewall, public IP, game version and client compatibility.

## 4. Current blockers
- Existing code contains placeholder DB credentials and has not been compiled.
- No cloud VPS or database has been provisioned from this repository.
- GitHub Actions is static validation only, not a running game server.
- Full banking, salaries, properties, police, families, proximity voice and custom Android assets remain unimplemented.
- Do NOT run this as a public server until authentication, transaction security and deployment are validated.
