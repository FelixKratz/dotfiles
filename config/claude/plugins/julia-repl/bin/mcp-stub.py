#!/usr/bin/env python3
"""A stdio MCP server with no tools.

Stands in for AgentREPL outside a Julia project, so Claude Code sees a
connected server and never reports a failure for a session that simply
has no Julia in it. It sends no instructions, which would otherwise land
in every such session's context.
"""

import json
import sys

LISTS = {
    "tools/list": "tools",
    "resources/list": "resources",
    "resources/templates/list": "resourceTemplates",
    "prompts/list": "prompts",
}


def reply(msg_id, result=None, error=None):
    out = {"jsonrpc": "2.0", "id": msg_id}
    if error is None:
        out["result"] = result
    else:
        out["error"] = error
    sys.stdout.write(json.dumps(out) + "\n")
    sys.stdout.flush()


for line in sys.stdin:
    try:
        msg = json.loads(line)
    except ValueError:
        continue
    if "id" not in msg:
        continue
    method = msg.get("method")
    if method == "initialize":
        version = msg.get("params", {}).get("protocolVersion", "2025-06-18")
        reply(msg["id"], {
            "protocolVersion": version,
            "capabilities": {},
            "serverInfo": {"name": "julia-repl", "version": "0"},
        })
    elif method == "ping":
        reply(msg["id"], {})
    elif method in LISTS:
        reply(msg["id"], {LISTS[method]: []})
    else:
        reply(msg["id"], error={"code": -32601,
                                "message": "no Julia project in this session"})
