#!/usr/bin/env python3
"""Server-side Firestore rules tests (no emulator needed).

Runs allow/deny cases for firebase/firestore.rules through the Firebase Rules
API `projects.test` endpoint, mocking get()/exists()/getAfter()/existsAfter()
from an in-memory world. Nothing is read from or written to the database.

Usage (needs `firebase login`):
    python3 firebase/rules_test.py [project-id]
"""
import copy
import json
import os
import sys
import urllib.request

PROJECT = sys.argv[1] if len(sys.argv) > 1 else "build-kapok"
RULES = os.path.join(os.path.dirname(__file__), "firestore.rules")
DB = "/databases/(default)/documents"


def token():
    cfg = os.path.expanduser("~/.config/configstore/firebase-tools.json")
    with open(cfg) as f:
        return json.load(f)["tokens"]["access_token"]


# ---------------- world ----------------
WORLD = {
    "users/admin": {"userRole": "admin"},
    "users/leaderA": {"userRole": "teamLeader", "teamId": "teamA"},
    "users/memberA": {"userRole": "teamMember", "teamId": "teamA"},
    "users/member2A": {"userRole": "teamLeader", "teamId": "teamA"},
    "users/leaderB": {"userRole": "teamLeader", "teamId": "teamB"},
    "users/memberB": {"userRole": "teamMember", "teamId": "teamB"},
    "users/stranger": {"userRole": "teamMember"},
    "teams/teamA": {
        "leaderId": "leaderA", "teamCode": "AAAAAA", "isActive": True,
        "memberIds": ["leaderA", "memberA", "member2A"], "taskIds": ["taskA"],
        "teamName": "A",
    },
    "teams/teamB": {
        "leaderId": "leaderB", "teamCode": "BBBBBB", "isActive": True,
        "memberIds": ["leaderB", "memberB"], "taskIds": ["taskB"],
        "teamName": "B",
    },
    "teamCodes/AAAAAA": {"teamId": "teamA"},
    "teamCodes/BBBBBB": {"teamId": "teamB"},
    "tasks/taskA": {"teamId": "teamA", "createdBy": "memberA", "assignedTo": "member2A", "title": "a"},
    "tasks/taskOld": {"teamId": "teamA", "createdBy": "stranger", "assignedTo": "stranger", "title": "old"},
    "tasks/taskOld2": {"teamId": "teamA", "createdBy": "stranger", "assignedTo": "memberA", "title": "old2"},
    "tasks/taskB": {"teamId": "teamB", "createdBy": "memberB", "title": "b"},
}


def mocks(before, after):
    out = []
    paths = set(before) | set(after)
    for p in paths:
        full = f"{DB}/{p}"
        for fn, state in (("get", before), ("exists", before),
                          ("getAfter", after), ("existsAfter", after)):
            present = p in state
            if fn.startswith("exists"):
                out.append({"function": fn, "args": [{"exactValue": full}],
                            "result": {"value": present}})
            elif present:
                out.append({"function": fn, "args": [{"exactValue": full}],
                            "result": {"value": {"data": state[p], "id": p.split("/")[-1]}}})
    # Unknown documents don't exist.
    for fn in ("exists", "existsAfter"):
        out.append({"function": fn, "args": [{"anyValue": {}}], "result": {"value": False}})
    return out


CASES = []


def case(name, expect, uid, method, path, data=None, writes=None):
    """writes: extra {path: data|None} applied to the 'after' world (batch)."""
    before = copy.deepcopy(WORLD)
    after = copy.deepcopy(WORLD)
    if method in ("create", "update"):
        after[path] = data
    if method == "delete":
        after.pop(path, None)
    for p, d in (writes or {}).items():
        if d is None:
            after.pop(p, None)
        else:
            after[p] = d
    req = {"auth": {"uid": uid} if uid else None,
           "path": f"{DB}/{path}", "method": method}
    if data is not None:
        req["resource"] = {"data": data}
    tc = {"expectation": expect, "request": req,
          "functionMocks": mocks(before, after)}
    if path in WORLD:
        tc["resource"] = {"data": WORLD[path]}
    CASES.append((name, tc))


def upd(path, **changes):
    d = copy.deepcopy(WORLD[path])
    for k, v in changes.items():
        if v is None:
            d.pop(k, None)
        else:
            d[k] = v
    return d


A, D = "ALLOW", "DENY"

# --- users ---
case("user reads self", A, "stranger", "get", "users/stranger")
case("member reads teammate", A, "memberA", "get", "users/leaderA")
case("member reads other team's user", D, "memberA", "get", "users/memberB")
case("stranger reads team member", D, "stranger", "get", "users/memberA")
case("admin reads anyone", A, "admin", "get", "users/memberB")
case("leader clears own member's teamId", A, "leaderA", "update", "users/memberA",
     upd("users/memberA", teamId=None))
case("leader clears other team's user teamId", D, "leaderA", "update", "users/memberB",
     upd("users/memberB", teamId=None))
case("leader sets own member's specialty role", A, "leaderA", "update", "users/memberA",
     upd("users/memberA", role="Medical"))
case("leader changes member's userRole", D, "leaderA", "update", "users/memberA",
     upd("users/memberA", userRole="admin"))
case("user edits own profile", A, "memberA", "update", "users/memberA",
     upd("users/memberA", name="New"))
case("user creates own doc", A, "newbie", "create", "users/newbie", {"userRole": "teamMember"})
case("user creates someone else's doc", D, "newbie", "create", "users/other", {"userRole": "teamMember"})

# --- teams: read ---
case("member reads team", A, "memberA", "get", "teams/teamA")
case("stranger reads team", D, "stranger", "get", "teams/teamA")
case("other leader reads team", D, "leaderB", "get", "teams/teamA")

# --- team codes ---
case("stranger looks up code", A, "stranger", "get", "teamCodes/AAAAAA")
case("stranger lists codes", D, "stranger", "list", "teamCodes/AAAAAA")
case("leader backfills own code", A, "leaderA", "create", "teamCodes/AAAAAA",
     {"teamId": "teamA"})
case("stranger forges code for teamA", D, "stranger", "create", "teamCodes/ZZZZZZ",
     {"teamId": "teamA"})
case("code doc can't be repointed", D, "leaderA", "update", "teamCodes/AAAAAA",
     {"teamId": "teamB"})

# --- teams: create ---
new_team = {"leaderId": "stranger", "teamCode": "NEWNEW", "isActive": True,
            "memberIds": ["stranger"], "taskIds": [], "teamName": "N"}
case("create team with reserved code", A, "stranger", "create", "teams/teamN", new_team,
     writes={"teamCodes/NEWNEW": {"teamId": "teamN"}})
case("create team without code doc", D, "stranger", "create", "teams/teamN", new_team)
case("create team for someone else", D, "stranger", "create", "teams/teamN",
     dict(new_team, leaderId="leaderA", memberIds=["leaderA"]),
     writes={"teamCodes/NEWNEW": {"teamId": "teamN"}})
case("create team pre-filled with members", D, "stranger", "create", "teams/teamN",
     dict(new_team, memberIds=["stranger", "memberA"]),
     writes={"teamCodes/NEWNEW": {"teamId": "teamN"}})
case("code doc + team in one batch", A, "stranger", "create", "teamCodes/NEWNEW",
     {"teamId": "teamN"}, writes={"teams/teamN": new_team})

# --- teams: join ---
joined = upd("teams/teamA", memberIds=["leaderA", "memberA", "member2A", "stranger"])
case("join with correct code", A, "stranger", "update", "teams/teamA", joined,
     writes={"users/stranger": dict(WORLD["users/stranger"], teamId="teamA", joinCode="AAAAAA")})
case("join with wrong code", D, "stranger", "update", "teams/teamA", joined,
     writes={"users/stranger": dict(WORLD["users/stranger"], teamId="teamA", joinCode="BBBBBB")})
case("join without code", D, "stranger", "update", "teams/teamA", joined)
case("join adds someone else too", D, "stranger", "update", "teams/teamA",
     upd("teams/teamA", memberIds=["leaderA", "memberA", "member2A", "stranger", "memberB"]),
     writes={"users/stranger": dict(WORLD["users/stranger"], joinCode="AAAAAA")})

# --- teams: leader / leave / transfer ---
case("leader renames own team", A, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", teamName="A2"))
case("leader renames other team", D, "leaderA", "update", "teams/teamB",
     upd("teams/teamB", teamName="pwned"))
case("leader closes own team", A, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", isActive=False))
case("leader removes member", A, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", memberIds=["leaderA", "member2A"]))
case("leader force-adds a member", D, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", memberIds=["leaderA", "memberA", "member2A", "memberB"]))
case("leader changes teamCode", D, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", teamCode="XXXXXX"))
case("member leaves", A, "memberA", "update", "teams/teamA",
     upd("teams/teamA", memberIds=["leaderA", "member2A"]))
case("member removes someone else", D, "memberA", "update", "teams/teamA",
     upd("teams/teamA", memberIds=["leaderA", "memberA"]))
case("transfer to member with leader role", A, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", leaderId="member2A"))
case("transfer to member without leader role", D, "leaderA", "update", "teams/teamA",
     upd("teams/teamA", leaderId="memberA"))
case("member adds taskId", A, "memberA", "update", "teams/teamA",
     upd("teams/teamA", taskIds=["taskA", "taskN"]))
case("stranger adds taskId", D, "stranger", "update", "teams/teamA",
     upd("teams/teamA", taskIds=["taskA", "taskN"]))
case("leader deletes own team", A, "leaderA", "delete", "teams/teamA")
case("leader deletes other team", D, "leaderA", "delete", "teams/teamB")

# --- tasks ---
case("member reads team task", A, "memberA", "get", "tasks/taskA")
case("stranger reads task", D, "stranger", "get", "tasks/taskA")
case("other leader reads task", D, "leaderB", "get", "tasks/taskA")
case("admin reads task", A, "admin", "get", "tasks/taskB")
case("member creates task in own team", A, "memberA", "create", "tasks/taskN",
     {"teamId": "teamA", "createdBy": "memberA", "title": "n"})
case("stranger creates task in team", D, "stranger", "create", "tasks/taskN",
     {"teamId": "teamA", "createdBy": "stranger", "title": "n"})
case("create task as someone else", D, "memberA", "create", "tasks/taskN",
     {"teamId": "teamA", "createdBy": "member2A", "title": "n"})
case("assignee completes task", A, "member2A", "update", "tasks/taskA",
     upd("tasks/taskA", status="completed"))
case("leader edits team task", A, "leaderA", "update", "tasks/taskA",
     upd("tasks/taskA", title="x"))
case("other leader edits task", D, "leaderB", "update", "tasks/taskA",
     upd("tasks/taskA", title="pwned"))
case("creator moves task to other team", D, "memberA", "update", "tasks/taskA",
     upd("tasks/taskA", teamId="teamB"))
case("creator anonymizes own task", A, "memberA", "update", "tasks/taskA",
     upd("tasks/taskA", createdBy="deleted_user"))
case("assignee rewrites createdBy", D, "member2A", "update", "tasks/taskA",
     upd("tasks/taskA", createdBy="member2A"))
case("leader unassigns member", A, "leaderA", "update", "tasks/taskA",
     upd("tasks/taskA", assignedTo=None))
case("other leader deletes task", D, "leaderB", "delete", "tasks/taskA")
case("leader deletes team task", A, "leaderA", "delete", "tasks/taskA")
case("creator deletes own task", A, "memberA", "delete", "tasks/taskA")
case("non-creator member deletes task", D, "member2A", "delete", "tasks/taskA")

case("ex-member anonymizes own task", A, "stranger", "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], createdBy="deleted_user"))
case("ex-member anonymizes assigned task", A, "stranger", "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], assignedTo="deleted_user"))
case("ex-member anonymizes own self-assigned task (one write)", A, "stranger",
     "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], createdBy="deleted_user", assignedTo="deleted_user"))
case("ex-member anonymizes someone else's assignment", D, "stranger", "update",
     "tasks/taskOld2",
     dict(WORLD["tasks/taskOld2"], createdBy="deleted_user", assignedTo="deleted_user"))
case("ex-member anonymizes only own createdBy", A, "stranger", "update",
     "tasks/taskOld2", dict(WORLD["tasks/taskOld2"], createdBy="deleted_user"))
case("ex-member reassigns old task to self", D, "memberB", "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], assignedTo="memberB"))
case("ex-member edits old task", D, "stranger", "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], title="changed"))
case("ex-member anonymizes + edits", D, "stranger", "update", "tasks/taskOld",
     dict(WORLD["tasks/taskOld"], createdBy="deleted_user", title="changed"))

# --- map snapshots ---
case("own map snapshot", A, "memberA", "update", "mapSnapshots/memberA", {"x": 1})
case("other's map snapshot", D, "memberA", "get", "mapSnapshots/memberB")


def main():
    body = {
        "source": {"files": [{"name": "firestore.rules", "content": open(RULES).read()}]},
        "testSuite": {"testCases": [tc for _, tc in CASES]},
    }
    req = urllib.request.Request(
        f"https://firebaserules.googleapis.com/v1/projects/{PROJECT}:test",
        data=json.dumps(body).encode(),
        headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as r:
        res = json.load(r)
    for issue in res.get("issues", []):
        print("ISSUE:", issue)
    failed = 0
    for (name, tc), result in zip(CASES, res.get("testResults", [])):
        ok = result.get("state") == "SUCCESS"
        failed += not ok
        print(f"{'PASS' if ok else 'FAIL'}  [{tc['expectation']:5}] {name}")
        if not ok:
            for line in result.get("debugMessages", [])[:3]:
                print("        ", line)
            if result.get("errorPosition"):
                print("         at", result["errorPosition"])
    print(f"\n{len(CASES) - failed}/{len(CASES)} passed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
