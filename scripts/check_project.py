#!/usr/bin/env python3
"""Lightweight repository validation. This does NOT compile Pawn."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parents[1]
source = (root / "gamemodes/omarrp.pwn").read_text()
schema = (root / "database/schema.sql").read_text()
config = json.loads((root / "config.json").read_text())
assert config["max_players"] == 100
assert config["network"]["port"] == 7777
for table in ("accounts", "ledger", "job_progress", "families", "family_members", "admin_audit"):
    assert re.search(r"CREATE TABLE\s+" + table + r"\b", schema), table
for feature in ("AccountLookup", "AccountLoaded", "OnPlayerSpawn", "OnPlayerCommandText"):
    assert feature in source, feature
assert "bcrypt_hash(" in source
assert "bcrypt_verify(" in source
assert "ResetPlayerMoney(playerid);" in source
print("Static repository checks passed (NOT a Pawn compile).")
