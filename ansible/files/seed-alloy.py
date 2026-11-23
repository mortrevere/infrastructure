"""Set Alloy's initial cursors once. Run before starting Compose."""
import json
import pathlib
import subprocess
import time


def write_once(path, content):
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        temporary = path.with_suffix(".tmp")
        temporary.write_text(content)
        temporary.replace(path)


state = pathlib.Path("/var/lib/alloy")
journal_seed = state / "loki.source.journal.host" / "positions.yml"
if not journal_seed.exists():
    output = subprocess.check_output(
        ["journalctl", "-n", "1", "--show-cursor", "-o", "cat", "--quiet", "--no-pager"],
        text=True,
    )
    cursor = next(line.removeprefix("-- cursor: ") for line in output.splitlines()
                  if line.startswith("-- cursor: "))
    key = json.dumps({"path": "cursor-loki.source.journal.host", "labels": ""})
    write_once(journal_seed, f"positions:\n  ? {key}\n  : {json.dumps(cursor)}\n")

docker_positions = state / "loki.source.docker.umami" / "positions.yml"
if not docker_positions.exists():
    since = str(int(time.time()) + 1)
    containers = subprocess.check_output(
        ["docker", "ps", "-a", "--no-trunc", "--filter", "label=com.docker.compose.project=umami",
         "--format", "{{.ID}} {{.Names}}"],
        text=True,
    )
    # Alloy v1.16.1 uses the container ID and sorted discovery labels as its key.
    entries = []
    for line in containers.splitlines():
        container_id, name = line.split()
        labels = ('{__meta_docker_container_id="' + container_id
                  + '", __meta_docker_container_name="/' + name + '"}')
        key = json.dumps({"path": "cursor-" + container_id, "labels": labels})
        entries.append(f"  ? {key}\n  : {json.dumps(since)}\n")
    write_once(docker_positions, "positions:\n" + "".join(entries) if entries else "positions: {}\n")
