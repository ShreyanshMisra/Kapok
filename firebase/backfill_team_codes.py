#!/usr/bin/env python3
"""One-off: create /teamCodes/{code} -> {teamId} for existing active teams.

The new Firestore rules resolve invite codes through /teamCodes, so teams
created before that collection existed can't be joined until indexed. (The app
also backfills a team the first time its leader loads it; this script covers
teams whose leader doesn't open the app.)

Uses your `firebase login` OAuth token (project owner/editor), which bypasses
security rules. Dry run by default.

Usage:
    python3 firebase/backfill_team_codes.py            # dry run
    python3 firebase/backfill_team_codes.py --apply    # write
"""
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

PROJECT = "build-kapok"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"
APPLY = "--apply" in sys.argv


def token():
    cfg = os.path.expanduser("~/.config/configstore/firebase-tools.json")
    with open(cfg) as f:
        return json.load(f)["tokens"]["access_token"]


TOKEN = token()


def call(method, url, body=None):
    req = urllib.request.Request(
        url, method=method,
        data=json.dumps(body).encode() if body is not None else None,
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def teams():
    page = None
    while True:
        url = f"{BASE}/teams?pageSize=300" + (f"&pageToken={page}" if page else "")
        res = call("GET", url)
        yield from res.get("documents", [])
        page = res.get("nextPageToken")
        if not page:
            return


created = skipped = 0
for doc in teams():
    team_id = doc["name"].rsplit("/", 1)[-1]
    fields = doc.get("fields", {})
    code = fields.get("teamCode", {}).get("stringValue", "")
    active = fields.get("isActive", {}).get("booleanValue", True)
    if not code or not active:
        skipped += 1
        continue
    try:
        existing = call("GET", f"{BASE}/teamCodes/{urllib.parse.quote(code)}")
        owner = existing["fields"]["teamId"]["stringValue"]
        if owner != team_id:
            print(f"CONFLICT code {code}: indexed for {owner}, also used by {team_id}")
        skipped += 1
        continue
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise
    print(f"{'create' if APPLY else 'would create'} teamCodes/{code} -> {team_id}")
    if APPLY:
        call("POST", f"{BASE}/teamCodes?documentId={urllib.parse.quote(code)}", {
            "fields": {
                "teamId": {"stringValue": team_id},
                "createdAt": {"timestampValue": doc.get("createTime")},
            }
        })
    created += 1

print(f"\n{created} {'created' if APPLY else 'to create'}, {skipped} skipped")
if not APPLY:
    print("Dry run. Re-run with --apply to write.")
