# Omar RP technical specification — v0.1

## Fixed decisions
- Android-first, ReSA ordinary client; open.mp server
- 100 concurrent players target (load testing required)
- Medium RP; Los Santos with Omar District, Motor City, Ocean Boulevard, Industrial Park
- Balanced graphics; optional asset packs tested per Android device tier
- New player balance: $2,000
- Payroll interval: 1,800 seconds of verified active work, not idle time
- Family creation fee: $50,000

## Implementation order
1. Accounts + persistent SQL database, authentication, safe spawn and transactions
2. Economy + bank + audit trail + anti-duplication checks
3. Jobs and server-authoritative active-work payroll
4. Vehicle ownership, garages, fuel, repairs
5. Administration and moderation logging
6. Police ranks, arrests, fines and jail
7. Properties and ownership
8. Families, ranks, invitations and shared assets
9. Proximity voice (requires Android client/plugin compatibility test)
10. Custom mapping and balanced client asset packs
11. Stress tests at 20, 50 and 100 active players

## Security requirements
Never trust client-submitted money or rank values. Persist balance changes in atomic database transactions. Use parameterized SQL. Protect RCON and database secrets outside Git. Require audit logs for money edits and moderation actions.

## Limitations
Current source only includes basic spawning, a demo cash amount and four map objects. It does not include a database, salary logic, families, voice, or a verified Android build. Replace prototype cash reset with persistent accounts before public testing.
