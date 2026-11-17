# Omar RP — Android Medium RP
Open.MP server starter targeting 100 concurrent players, with ReSA Android client compatibility to be verified in live tests.

## Current scope
- Los Santos base map + preliminary Omar District objects near Ganton
- Starting cash: $2,000
- Salary cycle: 30 minutes of *active* gameplay (specification only; not yet implemented)
- Family creation fee: $50,000 (specification only; not yet implemented)
- Balanced graphics (client-side asset pack planned)
- Police, jobs, banking, vehicles, properties, families, proximity voice and administration are planned modules, not implemented.

## Build
Install the open.mp server and a matching Pawn compiler and open.mp includes on a Linux host. Compile `gamemodes/omarrp.pwn` to `gamemodes/omarrp.amx` using the compiler/includes supplied with your open.mp installation. Copy `config.json` to the server root and launch the open.mp server binary. Do not expect GitHub to host a game server.

## Testing
1. Compile without warnings/errors.
2. Join from a supported PC client, then from ReSA Android.
3. Check spawn, cash, /help, /district and district object placement.
4. Verify compatibility before adding custom DFF/TXD assets or voice plugins.
5. Load-test with increasing player counts before advertising 100 CCU.

This is a development starter, not a production-ready roleplay server.
