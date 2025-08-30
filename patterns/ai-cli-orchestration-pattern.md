# AI + CLI Orchestration Pattern

## A Framework for Intelligent Tool Orchestration with Claude Code

> **Core idea:** AI plans and supervises; deterministic tools execute. The interface between them is a small, versioned, machine‑parsable protocol.

---

## Table of Contents

- [AI + CLI Orchestration Pattern](#ai--cli-orchestration-pattern)
  - [A Framework for Intelligent Tool Orchestration with Claude Code](#a-framework-for-intelligent-tool-orchestration-with-claude-code)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Protocol \& Contracts](#protocol--contracts)
    - [Streaming JSONL Protocol](#streaming-jsonl-protocol)
    - [Message Types](#message-types)
    - [Error Taxonomy](#error-taxonomy)
    - [Run State Machine](#run-state-machine)
    - [Timeouts, Heartbeats, Cancellation](#timeouts-heartbeats-cancellation)
  - [Architecture Overview](#architecture-overview)
    - [System Components](#system-components)
    - [Execution Flow](#execution-flow)
  - [Security \& Permissions](#security--permissions)
  - [Setting Up the CLI System](#setting-up-the-cli-system)
    - [1) Create the Universal Runner (cross‑platform)](#1-create-the-universal-runner-crossplatform)
    - [2) Create a Project Shortcut](#2-create-a-project-shortcut)
    - [3) Dependencies \& Reproducibility](#3-dependencies--reproducibility)
  - [Responsibility Separation](#responsibility-separation)
  - [Tool Registry \& Manifest](#tool-registry--manifest)
  - [Claude Integration](#claude-integration)
    - [Slash Commands](#slash-commands)
  - [Implementation Guide](#implementation-guide)
  - [Best Practices](#best-practices)
  - [Examples](#examples)
    - [Example 1: `example_processor` (schema‑checked, JSONL)](#example-1-example_processor-schemachecked-jsonl)
    - [Example 2: `data_migrator` (batched, retryable errors, checkpoints)](#example-2-data_migrator-batched-retryable-errors-checkpoints)
    - [Example 3: Workflow Orchestrator (actual subprocess + parallel tasks)](#example-3-workflow-orchestrator-actual-subprocess--parallel-tasks)
  - [Troubleshooting](#troubleshooting)
  - [Non‑Goals \& Tradeoffs](#nongoals--tradeoffs)
  - [Conclusion \& Next Steps](#conclusion--next-steps)

---

## Introduction

This pattern describes how to build AI‑augmented systems where Claude Code orchestrates deterministic CLI tools to solve real work: multi‑step workflows, reliable operations, stateful recovery, and auditable decisions. The AI decides *what* to do and *when* to do it; tools guarantee *how* it’s done.

**When to use**

* Multi‑step workflows needing judgment + strict execution
* Long‑running jobs with checkpoints and resumption
* Clear audit trails of “AI decided X; tool did Y”
* Incremental extensibility: add tools and workers over time

**Benefits**

* Predictable intelligence inside deterministic guardrails
* Resumable operations with explicit state
* Traceable decisions and outcomes
* Maintainable separation of concerns
* Scalable: add tools, not complexity

---

## Protocol & Contracts

Design everything around a small, versioned, **JSONL** streaming protocol over stdout. This is the contract between AI and tools. Humans can read logs; machines can parse events. No emojis, no prose parsing.

### Streaming JSONL Protocol

* Each line on **stdout** is a complete JSON object.
* **stderr** is for human diagnostics only (not parsed).
* Required envelope fields:

```json
{
  "v": 1,                    // protocol version
  "type": "progress",        // message kind
  "ts": "2025-08-30T12:34:56Z",
  "run_id": "r-123",         // stable for a run
  "trace_id": "t-abc",       // optional for distributed tracing
  "span_id": "s-001"         // optional
}
```

Recommended environment variables injected by the runner:

* `RUN_ID`, `TRACE_ID`
* `WORKSPACE` (ephemeral working dir)
* `DEADLINE_TS` (ISO8601)
* `CANCEL_FILE` (path watched for cancellation)
* `AI_PROTOCOL_VERSION` (expected protocol `v`)
* `LOG_DIR` (where the runner stores logs/artifacts)

### Message Types

Below are the canonical types and their minimal fields. Tools can include additional fields under `context` or `metrics`.

```json
{"v":1,"type":"start","ts":"...","run_id":"...","step":"analyze","args":{"input":"data.json"}}
{"v":1,"type":"progress","ts":"...","run_id":"...","step":"analyze","pct":37.5,"msg":"Reading shard 3/8"}
{"v":1,"type":"heartbeat","ts":"...","run_id":"...","step":"analyze"}
{"v":1,"type":"action_required","ts":"...","run_id":"...","action":"choose_migration_strategy","context":{"files":1234,"batch_size":50}}
{"v":1,"type":"result","ts":"...","run_id":"...","status":"ok","artifacts":[{"path":"./out/report.json","sha256":"..."}],"metrics":{"rows":42017,"duration_s":12.4}}
{"v":1,"type":"error","ts":"...","run_id":"...","code":"E_INPUT_NOT_FOUND","msg":"data.json not found","hint":"Check path or mount","retryable":false}
{"v":1,"type":"cancelled","ts":"...","run_id":"...","reason":"cancel-file"}
{"v":1,"type":"log","ts":"...","run_id":"...","level":"info","msg":"Validated schema v2.1"}
{"v":1,"type":"task_submitted","ts":"...","run_id":"...","task_id":"t-5","payload":{"command":"transform --part 5"}}
{"v":1,"type":"task_started","ts":"...","run_id":"...","task_id":"t-5"}
{"v":1,"type":"task_done","ts":"...","run_id":"...","task_id":"t-5","status":"ok"}
```

### Error Taxonomy

Map errors to classes and default AI actions:

| `code`              | Class         | Default AI Action                 |
| ------------------- | ------------- | --------------------------------- |
| `E_INPUT_NOT_FOUND` | user\_error   | Ask user to fix; don’t retry      |
| `E_SCHEMA_MISMATCH` | user\_error   | Request mapping or schema update  |
| `E_TRANSIENT_NET`   | retryable     | Retry with backoff (e.g., 3×)     |
| `E_RATE_LIMIT`      | retryable     | Backoff + reduce concurrency      |
| `E_DEADLINE`        | infra\_error  | Split workload / lower batch size |
| `E_DISK_FULL`       | infra\_error  | Free space or move workspace      |
| `E_PERMISSION`      | policy\_error | Adjust permissions; do not retry  |
| `E_UNKNOWN`         | unknown       | Triage; attach `context` and logs |

### Run State Machine

Deterministic run lifecycle:

```
queued → running → (waiting_ai)* → running → completed | failed | cancelled
```

* `waiting_ai` occurs after `action_required`.
* Tools must emit `start` once; `result` or `error` finalizes the run.
* Runner enforces deadlines and cancellation.

### Timeouts, Heartbeats, Cancellation

* Tools emit `heartbeat` at least every **30s**.
* Runner kills the process if no `progress`/`heartbeat` for **N** seconds (configurable).
* Cancellation: the runner creates a `CANCEL_FILE`. Tools check it between batches and emit `cancelled` before exiting with a non‑zero exit code (e.g., 130).

Minimal emitter helper:

```python
# tools/_lib/protocol.py
import json, os, sys, time, uuid

RUN_ID = os.environ.get("RUN_ID", str(uuid.uuid4()))

def _emit(payload: dict):
    payload.setdefault("v", 1)
    payload.setdefault("ts", time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
    payload.setdefault("run_id", RUN_ID)
    sys.stdout.write(json.dumps(payload) + "\n")
    sys.stdout.flush()

def emit_start(step, **kw):          _emit({"type":"start","step":step, **kw})
def emit_progress(step,pct,msg=""):  _emit({"type":"progress","step":step,"pct":pct,"msg":msg})
def emit_heartbeat(step):            _emit({"type":"heartbeat","step":step})
def emit_action(action, **ctx):      _emit({"type":"action_required","action":action,"context":ctx})
def emit_result(status="ok", **kw):  _emit({"type":"result","status":status, **kw})
def emit_error(code,msg,hint="",**kw):_emit({"type":"error","code":code,"msg":msg,"hint":hint, **kw})
def emit_log(level,msg,**kw):        _emit({"type":"log","level":level,"msg":msg, **kw})
def emit_cancelled(reason):          _emit({"type":"cancelled","reason":reason})
```

---

## Architecture Overview

### System Components

```
project/
├── tools/
│   ├── run.py                 # Universal runner (cross‑platform)
│   ├── registry/              # Tool registry + manifests
│   │   └── <tool>/tool.yaml
│   ├── <tool>/                # Tool implementation
│   │   ├── cli.py
│   │   ├── venv/              # Optional per‑tool venv
│   │   └── _lib/              # Tool libs (protocol, checkpoints)
│   └── shared_venv/           # Optional shared venv
├── .runs/                     # Run artifacts, logs, events
│   └── r-<id>/events.jsonl
├── .claude/                   # Claude Code config
│   ├── commands/
│   └── agents/
└── docs/
```

### Execution Flow

1. **User request** → Claude interprets intent.
2. **AI decision** → Selects tool(s) + parameters.
3. **Runner** → Spawns tool inside an isolated workspace with scoped env.
4. **Tool** → Streams JSONL events; writes artifacts to workspace.
5. **AI** → Consumes events, answers `action_required`, monitors heartbeats.
6. **Result** → AI synthesizes output, emits summary + artifacts.

---

## Security & Permissions

Minimum posture for production:

* **Ephemeral workspace** per run under `.runs/r-<id>/work/`.
* **Drop privileges:** non‑root user, `ulimit` caps, capped output size.
* **Scoped environment:** explicit allowlist; no ambient secrets.
* **Filesystem allowlists:** tools may read/write only under `WORKSPACE` (unless manifest allows more).
* **Network egress allowlist:** default deny; allow specific hosts/ports per tool manifest.
* **Secrets** via files with `0o600` permissions; never printed; redacted in logs.
* **Policy guard:** runner rejects tools whose requested permissions exceed org policy.

Optional hardening:

* Containerize tools (Docker/Podman) or Linux user/ns + seccomp.
* Use OPA/Rego for policy if needs grow.

---

## Setting Up the CLI System

### 1) Create the Universal Runner (cross‑platform)

```python
# tools/run.py
#!/usr/bin/env python3
import os, sys, json, shutil, signal, time, tempfile, subprocess, uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLS_DIR = ROOT / "tools"
REGISTRY_DIR = TOOLS_DIR / "registry"
RUNS_DIR = ROOT / ".runs"
LOGS_DIR = ROOT / ".runs"
DEFAULT_TIMEOUT_S = int(os.environ.get("TOOL_TIMEOUT_S", "1800"))
HEARTBEAT_GRACE_S = int(os.environ.get("HEARTBEAT_GRACE_S", "90"))

def _python_for(tool_dir: Path) -> Path:
    win = os.name == "nt"
    # Prefer per‑tool venv
    pt = tool_dir / ("venv\\Scripts\\python.exe" if win else "venv/bin/python")
    if pt.exists(): return pt
    # Fallback: shared venv
    shared = TOOLS_DIR / ("shared_venv\\Scripts\\python.exe" if win else "shared_venv/bin/python")
    if shared.exists(): return shared
    # Last resort: current interpreter
    return Path(sys.executable)

def _entry_for(tool: str) -> Path:
    td = TOOLS_DIR / tool
    for e in ("cli.py","main.py"):
        p = td / e
        if p.exists(): return p
    raise SystemExit(f"Tool '{tool}' has no entry (cli.py/main.py)")

def _load_manifest(tool: str) -> dict:
    mf = REGISTRY_DIR / tool / "tool.yaml"
    if not mf.exists():
        return {"name": tool, "version":"0.0.0", "permissions":{}, "resources":{}}
    import yaml
    return yaml.safe_load(mf.read_text())

def _mk_run_dirs(run_id: str):
    base = RUNS_DIR / run_id
    (base / "work").mkdir(parents=True, exist_ok=True)
    (base / "logs").mkdir(parents=True, exist_ok=True)
    (base / "artifacts").mkdir(parents=True, exist_ok=True)
    return base

def _now_iso():
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

def _write_jsonl(path: Path, obj: dict):
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(obj) + "\n")

def run_tool(tool: str, args: list[str], timeout_s=DEFAULT_TIMEOUT_S) -> int:
    entry = _entry_for(tool)
    manifest = _load_manifest(tool)
    run_id = f"r-{uuid.uuid4().hex[:10]}"
    run_dir = _mk_run_dirs(run_id)
    work = run_dir / "work"
    events = run_dir / "events.jsonl"
    cancel_file = run_dir / "CANCEL"

    env = {}
    # Allowlist environment variables
    for k in ("PATH",):
        if k in os.environ: env[k] = os.environ[k]
    env.update({
        "RUN_ID": run_id,
        "WORKSPACE": str(work),
        "LOG_DIR": str(run_dir / "logs"),
        "CANCEL_FILE": str(cancel_file),
        "AI_PROTOCOL_VERSION": "1"
    })

    # Policy check (very simple example)
    perms = manifest.get("permissions", {})
    if perms.get("network", {}).get("egress_allow") in (["*"], "*"):
        raise SystemExit("Policy: wildcard egress not allowed")

    py = _python_for(TOOLS_DIR / tool)
    cmd = [str(py), str(entry), *args]

    proc = subprocess.Popen(
        cmd, cwd=work, env=env,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=1, text=True
    )

    last_event_ts = time.monotonic()
    _write_jsonl(events, {"v":1,"type":"runner_start","ts":_now_iso(),"run_id":run_id,
                          "tool":tool,"args":args,"timeout_s":timeout_s})

    try:
        for line in proc.stdout:
            line = line.rstrip("\n")
            # Mirror to stdout for the AI
            print(line)
            # Also persist to events log
            try:
                obj = json.loads(line)
                last_event_ts = time.monotonic()
                _write_jsonl(events, obj)
            except json.JSONDecodeError:
                _write_jsonl(events, {"v":1,"type":"runner_log","ts":_now_iso(),
                                      "run_id":run_id,"level":"warn","msg":"non-json stdout","line":line})
            # Heartbeat guard
            if time.monotonic() - last_event_ts > HEARTBEAT_GRACE_S:
                _write_jsonl(events, {"v":1,"type":"runner_error","ts":_now_iso(),
                                      "run_id":run_id,"code":"E_HEARTBEAT_MISSED"})
                proc.terminate()
                break

        try:
            proc.wait(timeout=timeout_s)
        except subprocess.TimeoutExpired:
            cancel_file.touch()
            proc.kill()
            _write_jsonl(events, {"v":1,"type":"runner_error","ts":_now_iso(),
                                  "run_id":run_id,"code":"E_TIMEOUT"})
            return 124

    finally:
        rc = proc.returncode if proc.returncode is not None else 1
        _write_jsonl(events, {"v":1,"type":"runner_end","ts":_now_iso(),"run_id":run_id,"rc":rc})
    return rc

def main():
    if len(sys.argv) < 2:
        print("Usage: ./tool <tool_name> [args...] | --list | --describe <tool>", file=sys.stderr)
        return 1
    if sys.argv[1] == "--list":
        tools = sorted([p.name for p in TOOLS_DIR.iterdir() if p.is_dir() and (p/"cli.py").exists()])
        for t in tools: print(t)
        return 0
    if sys.argv[1] == "--describe":
        tool = sys.argv[2]
        print(json.dumps(_load_manifest(tool), indent=2))
        return 0
    tool = sys.argv[1]; args = sys.argv[2:]
    return run_tool(tool, args)

if __name__ == "__main__":
    sys.exit(main())
```

### 2) Create a Project Shortcut

```python
# ./tool  (project root)  — make executable: chmod +x tool
#!/usr/bin/env python3
import sys, subprocess
from pathlib import Path
if __name__ == "__main__":
    runner = Path(__file__).parent / "tools" / "run.py"
    sys.exit(subprocess.call([sys.executable, str(runner), *sys.argv[1:]]))
```

### 3) Dependencies & Reproducibility

Prefer **per‑tool** virtualenvs to avoid dependency soup. If you keep a shared venv, lock it.

**Option A (simple):**

```bash
python3 -m venv tools/shared_venv
source tools/shared_venv/bin/activate
pip install click pyyaml python-dateutil jsonschema pydantic portalocker
pip freeze > tools/requirements.txt
```

**Option B (deterministic):** use `pip-tools`

```bash
# tools/requirements.in (hand-maintained)
click
pyyaml
python-dateutil
jsonschema
pydantic
portalocker
# compile
pip-compile tools/requirements.in -o tools/requirements.txt
pip install -r tools/requirements.txt
```

---

## Responsibility Separation

**AI (non‑deterministic)**

* Understands user intent
* Plans steps and chooses tools
* Interprets errors and decides recovery
* Synthesizes results and writes the narrative

**CLI Tools (deterministic)**

* Execute file I/O, transforms, DB ops, network calls
* Maintain state, checkpoints, and progress
* Validate inputs/outputs against schemas
* Optimize performance, batching, caching

---

## Tool Registry & Manifest

Every tool declares capabilities and constraints in `tools/registry/<tool>/tool.yaml`:

```yaml
name: data_migrator
version: 1.2.0
entry: cli.py
protocol_version: 1
inputs:
  - {name: source, type: path, required: true}
  - {name: target, type: path, required: true}
permissions:
  filesystem:
    read: ["${WORKSPACE}/source/**"]
    write: ["${WORKSPACE}/migrated/**"]
  network:
    egress_allow: ["api.example.com:443"]
resources:
  cpu_seconds: 600
  memory_mb: 2048
env:
  require: ["AWS_REGION"]
exit_codes:
  ok: 0
  retryable_error: 20
  fatal_error: 30
health:
  selftest: ["--selftest"]
  describe: ["--describe"]
```

The runner exposes `./tool --describe <name>` to print the manifest for AI discovery.

---

## Claude Integration

### Slash Commands

````yaml
# .claude/commands/process_data.md
---
description: Process data files using CLI tools
allowed-tools: [Bash, Read, Write, Edit]
---

Process the data directory.

1. Inspect inputs:
   ```bash
   ./tool analyze_data --input-dir "$ARGUMENTS"
````

2. When the tool emits `{"type":"action_required","action":"choose_strategy"}`, decide based on file count.

3. Execute:

   ```bash
   ./tool process_data --strategy <selected> --input-dir "$ARGUMENTS"
   ```

4. Consume JSONL events; surface `result.artifacts` to the user; escalate on `error.retryable=true` with backoff.

````

### Agents / Workers

```yaml
# .claude/agents/data-processor.md
---
name: data-processor
description: Coordinates CLI tools with JSONL protocol
tools: [Bash, Read, Write]
---

- Start tools, stream JSONL, act on `action_required`.
- If `error.retryable` true: retry up to 3× with exponential backoff.
- On `progress.pct` stall and missing `heartbeat`: cancel and split workload.
- Use `--describe` to learn tool capabilities at runtime.
````

---

## Implementation Guide

1. **Scaffold**

   ```bash
   mkdir -p project/tools/registry project/.claude/{commands,agents} project/.runs
   python3 -m venv tools/shared_venv && source tools/shared_venv/bin/activate
   pip install -r tools/requirements.txt  # or use pip-tools as above
   ```
2. **Add the runner** (`tools/run.py`) and shortcut (`./tool`).
3. **Create your first tool** (`tools/example_processor/cli.py`) with the JSONL emitter.
4. **Define a manifest** (`tools/registry/example_processor/tool.yaml`).
5. **Add schema validation** (JSON Schema or Pydantic) for inputs/outputs.
6. **Enable checkpoints** with atomic writes and file locks.
7. **Add observability**: `.runs/r-*/events.jsonl`, per‑task logs, artifact hashes.
8. **Introduce parallelism** where needed with controlled concurrency and per‑task work dirs.
9. **Wire Claude** via slash commands and an agent that understands JSONL events.

---

## Best Practices

* **Single responsibility** per tool; idempotent operations preferred.
* **Strict contracts** at the boundary: validate inputs/outputs.
* **Explicit retries** only for retryable codes; never guess.
* **Small batches** + **checkpointing** to improve recovery.
* **Consistent message format** across tools.
* **Resource limits**: honor `cpu_seconds`, `memory_mb`, and deadlines.
* **Dry‑run & explain** modes for safety: show planned actions without side effects.
* **Secrets hygiene**: pass via files, redact logs, never echo.
* **Backpressure**: don’t flood the system; gate parallelism.

---

## Examples

### Example 1: `example_processor` (schema‑checked, JSONL)

```python
# tools/example_processor/cli.py
#!/usr/bin/env python3
import os, sys, json, time, hashlib
from pathlib import Path
from jsonschema import validate, ValidationError
sys.path.append(str(Path(__file__).parent / "_lib"))
from protocol import emit_start, emit_progress, emit_result, emit_error, emit_log, emit_heartbeat

INPUT_SCHEMA = {
  "type":"object",
  "properties":{"items":{"type":"array","items":{"type":"object"}}},
  "required":["items"]
}

def sha256sum(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""): h.update(chunk)
    return h.hexdigest()

def main():
    if "--selftest" in sys.argv:
        print(json.dumps({"selftest":"ok"})); return 0

    args = dict(zip(sys.argv[1::2], sys.argv[2::2]))
    input_path = Path(args.get("--input",""))
    output_path = Path(args.get("--output",""))

    if not input_path.exists():
        emit_error("E_INPUT_NOT_FOUND", f"Input not found: {input_path}", "Check path")
        return 30

    emit_start("process", args={"input": str(input_path)})
    try:
        data = json.loads(input_path.read_text())
        validate(instance=data, schema=INPUT_SCHEMA)
    except ValidationError as e:
        emit_error("E_SCHEMA_MISMATCH", "Input schema invalid", str(e)[:200])
        return 30
    except Exception as e:
        emit_error("E_UNKNOWN", "Failed to read input", str(e))
        return 30

    total = len(data["items"]) or 1
    out = {"original_keys": list(data.keys()), "item_count": total, "processed": True}

    for i, _ in enumerate(data["items"], 1):
        if i % 100 == 0:
            emit_progress("process", pct=(i/total)*100, msg=f"Processed {i}/{total}")
            emit_heartbeat("process")
        time.sleep(0.001)

    output_path.write_text(json.dumps(out, indent=2))
    artifact = {"path": str(output_path), "sha256": sha256sum(output_path)}
    emit_result(status="ok", artifacts=[artifact], metrics={"items": total})
    return 0

if __name__ == "__main__": sys.exit(main())
```

**Manifest**

```yaml
# tools/registry/example_processor/tool.yaml
name: example_processor
version: 0.1.0
entry: cli.py
protocol_version: 1
inputs:
  - {name: input, type: path, required: true}
  - {name: output, type: path, required: true}
permissions:
  filesystem:
    read:  ["${WORKSPACE}/**"]
    write: ["${WORKSPACE}/**"]
resources: { cpu_seconds: 60, memory_mb: 256 }
exit_codes: { ok: 0, retryable_error: 20, fatal_error: 30 }
health: { selftest: ["--selftest"], describe: ["--describe"] }
```

**Run**

```bash
./tool example_processor --input ./data.json --output ./result.json
```

---

### Example 2: `data_migrator` (batched, retryable errors, checkpoints)

```python
# tools/data_migrator/cli.py
#!/usr/bin/env python3
import os, sys, json, time
from pathlib import Path
sys.path.append(str(Path(__file__).parent / "_lib"))
from protocol import emit_start, emit_progress, emit_result, emit_error, emit_action, emit_heartbeat
from checkpoints import save_checkpoint, load_checkpoint

def transform(record: dict) -> dict:
    record = dict(record)
    record["migrated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    record["version"] = "2.0"
    return record

def main():
    args = dict(zip(sys.argv[1::2], sys.argv[2::2]))
    src = Path(args.get("--source",""))
    tgt = Path(args.get("--target",""))
    batch_size = int(args.get("--batch-size","100"))

    if not src.exists():
        emit_error("E_INPUT_NOT_FOUND", f"Source dir not found: {src}", "Check --source")
        return 30
    tgt.mkdir(parents=True, exist_ok=True)

    files = list(src.glob("*.json"))
    total = len(files)
    if total == 0:
        emit_error("E_INPUT_NOT_FOUND", "No JSON files to migrate", "Add files to source")
        return 30

    emit_start("migrate", args={"source": str(src), "target": str(tgt), "batch_size": batch_size})
    emit_action("choose_migration_strategy", files=total, batch_size=batch_size)

    cp = load_checkpoint("migrate") or {"i": 0}
    i = cp["i"]
    while i < total:
        end = min(i+batch_size, total)
        emit_progress("migrate", pct=(end/total)*100, msg=f"batch {i//batch_size+1}/{(total+batch_size-1)//batch_size}")
        for f in files[i:end]:
            try:
                data = json.loads(f.read_text())
                out = transform(data)
                (tgt / f.name).write_text(json.dumps(out))
            except Exception as e:
                # retryable on transient I/O
                emit_error("E_TRANSIENT_NET" if "HTTP" in str(e) else "E_UNKNOWN", f"Failed {f.name}", str(e), retryable=True)
                # Let AI decide to retry/skip/abort
                return 20
        i = end
        save_checkpoint("migrate", {"i": i})
        emit_heartbeat("migrate")

    emit_result(status="ok", artifacts=[{"path": str(tgt)}], metrics={"files": total})
    return 0

if __name__ == "__main__": sys.exit(main())
```

**Atomic checkpoints**

```python
# tools/data_migrator/_lib/checkpoints.py
import json, os, tempfile
from pathlib import Path

CP_DIR = Path(os.environ.get("WORKSPACE", ".")) / ".checkpoints"
CP_DIR.mkdir(parents=True, exist_ok=True)

def _atomic_write(path: Path, data: dict):
    fd, tmp = tempfile.mkstemp(dir=str(path.parent))
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    os.replace(tmp, path)

def save_checkpoint(stage: str, data: dict):
    _atomic_write(CP_DIR / f"{stage}.json", {"stage": stage, "data": data})

def load_checkpoint(stage: str):
    p = CP_DIR / f"{stage}.json"
    return json.loads(p.read_text())["data"] if p.exists() else None
```

---

### Example 3: Workflow Orchestrator (actual subprocess + parallel tasks)

```python
# tools/workflow_orchestrator/cli.py
#!/usr/bin/env python3
import os, sys, json, subprocess, concurrent.futures, shlex
from pathlib import Path
sys.path.append(str(Path(__file__).parent / "_lib"))
from protocol import emit_start, emit_progress, emit_result, emit_error, emit_action, emit_log

def run_cmd(cmd: str, cwd: Path, env: dict) -> int:
    p = subprocess.Popen(shlex.split(cmd), cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in p.stdout: print(line, end="")   # forward JSONL from child tools
    return p.wait()

def main():
    args = dict(zip(sys.argv[1::2], sys.argv[2::2]))
    wf_file = Path(args.get("--workflow",""))
    if not wf_file.exists():
        emit_error("E_INPUT_NOT_FOUND", f"Workflow not found: {wf_file}", "Check --workflow")
        return 30
    wf = json.loads(wf_file.read_text())
    steps = wf.get("steps", [])
    emit_start("workflow", args={"workflow": str(wf_file)})

    work = Path(os.environ["WORKSPACE"])
    env = os.environ.copy()

    for idx, step in enumerate(steps, 1):
        emit_progress("workflow", pct=(idx-1)/len(steps)*100, msg=f"step {idx}/{len(steps)}: {step['name']}")
        if step["type"] == "tool":
            rc = run_cmd(f"./tool {step['command']}", cwd=work, env=env)
            if rc != 0:
                emit_error("E_UNKNOWN", f"Step failed: {step['name']}", f"rc={rc}")
                return rc
        elif step["type"] == "ai_decision":
            emit_action(step["decision_type"], instruction=step.get("instruction",""))
        elif step["type"] == "parallel":
            tasks = step["tasks"]
            emit_log("info", f"Submitting {len(tasks)} tasks")
            with concurrent.futures.ThreadPoolExecutor(max_workers=step.get("max_concurrency", 4)) as pool:
                futs = [pool.submit(run_cmd, f"./tool {t}", work, env) for t in tasks]
                for f in concurrent.futures.as_completed(futs):
                    if f.result() != 0:
                        emit_error("E_UNKNOWN", "Parallel task failed", "")
                        return 1

    emit_result(status="ok")
    return 0

if __name__ == "__main__": sys.exit(main())
```

---

## Troubleshooting

**Tool not found**

* `./tool --list` to see discovered tools.
* Ensure `tools/<name>/cli.py` exists and is executable.
* Verify a manifest exists in `tools/registry/<name>/tool.yaml` (recommended).

**JSONL parse issues**

* Emit one JSON object per line.
* Keep `stderr` for diagnostics; protocol on **stdout** only.
* Validate messages with a JSON linter during development.

**No progress / heartbeat missed**

* Tools must emit `progress` or `heartbeat` at least every 30s.
* Runner kills the job after `HEARTBEAT_GRACE_S`.

**Timeouts**

* Increase `TOOL_TIMEOUT_S` if needed, or split batches.
* Check `DEADLINE_TS` and honor it inside the tool.

**Resume fails**

* Check `.runs/r-*/work/.checkpoints/*`.
* Ensure atomic writes (use `os.replace`) and consistent stage names.

**Parallel tasks interfere**

* Use per‑task working dirs if tasks write temp files.
* Avoid shared mutable state; pass inputs explicitly.

**Permissions / policy rejections**

* Adjust manifest `permissions` to avoid wildcards.
* Add necessary env var names to `env.require`.

---

## Non‑Goals & Tradeoffs

* **Not** a full workflow engine (Temporal/Dagster). It’s a lean contract + runner. If workflows balloon, migrate later.
* **Not** a security boundary on its own. Use containers or OS sandboxing if you run untrusted tools.
* **Not** a long‑term storage system. Artifacts live under `.runs/`; promote them elsewhere if needed.

---

## Conclusion & Next Steps

1. Adopt the **JSONL protocol** across all tools.
2. Replace ad‑hoc prints with the emitter helpers.
3. Use the **cross‑platform runner** with per‑tool venvs, timeouts, and logs.
4. Add **manifests** and a minimal **policy guard**.
5. Harden with **atomic checkpoints**, retry taxonomy, and workspace isolation.

Once those are in place, wire up Claude Code with a single agent that understands the protocol. You’ll get predictable runs, clean recovery, and an audit trail you can defend.

---

**Appendix: Quick Commands**

```bash
# List tools
./tool --list

# Describe a tool's capabilities
./tool --describe example_processor

# Run with a longer timeout (env var)
TOOL_TIMEOUT_S=3600 ./tool data_migrator --source ./in --target ./out --batch-size 200

# Enable debug logs (tool-defined)
TOOL_DEBUG=true ./tool example_processor --input data.json --output result.json
```
