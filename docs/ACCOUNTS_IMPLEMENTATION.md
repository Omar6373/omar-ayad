# Account system implementation contract

**Status:** Database schema added; Pawn/MySQL integration and authentication are NOT implemented yet.

## Required dependencies
- MariaDB/MySQL server with InnoDB
- open.mp compatible Pawn MySQL plugin + includes (pin exact versions after deployment target is chosen)
- bcrypt or Argon2 password hashing in a compatible server-side component; NEVER plain SHA-256 for passwords
- Store credentials in server-only environment/config, never commit them

## Registration and login
1. Normalize and validate player nickname; enforce 3–24 characters.
2. Query accounts with parameterized SQL.
3. For a new account, request a password through a dialog, hash with a strong password KDF, then insert.
4. For existing accounts, verify password with the same KDF.
5. Block all money/property/job commands until authenticated.
6. Apply login rate limits and temporary lockout; avoid revealing account existence.
7. On successful authentication load cash, bank, admin level and job progress.
8. On disconnect flush pending progress and invalidate session; never reset balance on respawn.

## Money operations
- All balance mutations happen server-side, in SQL transactions.
- Use SELECT ... FOR UPDATE to lock the account row, validate funds, then UPDATE balance and INSERT ledger row, COMMIT.
- Every payout and transfer has a unique transaction_key to prevent double-payment on retries.
- Use integer money values, never floats.
- For family creation lock the leader account, subtract exactly 50000, create family and membership, insert ledger entry, commit together.

## Payroll
- 1800 verified active work seconds per salary cycle.
- Work progress only increments for server-confirmed job actions; idle movement/chat does not count.
- Persist progress; reset or carry over remainder after successful payout.
- Payout idempotently using account id + payroll cycle number.
- Initial salary values and jobs are in docs/SPECIFICATION.md; tune after playtests.

## Test cases
- Reconnect retains $2000 registration balance
- Respawn never resets saved balance
- Duplicate payment key cannot pay twice
- Concurrent transfers cannot overdraw
- Family creation with $49999 fails, $50000 succeeds exactly once
- Incorrect password and repeated login attempts are throttled
- Crash during transfer either fully commits or fully rolls back

Do not deploy publicly until these cases pass.
