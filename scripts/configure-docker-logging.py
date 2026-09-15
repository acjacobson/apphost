#!/usr/bin/env python3
"""Set bounded Docker log defaults without replacing unrelated daemon settings."""
import json
import os
from pathlib import Path
import stat
import sys
import tempfile


def configure(path: Path) -> None:
    config = json.loads(path.read_text()) if path.exists() else {}
    if not isinstance(config, dict):
        raise ValueError("Docker daemon configuration must be a JSON object")
    driver = config.get("log-driver", "json-file")
    if driver != "json-file":
        print(f"Keeping existing logging driver {driver!r}; verify its retention separately.")
        return
    options = config.setdefault("log-opts", {})
    if not isinstance(options, dict):
        raise ValueError("Docker log-opts must be a JSON object")
    config["log-driver"] = "json-file"
    options.setdefault("max-size", "10m")
    options.setdefault("max-file", "3")
    content = json.dumps(config, indent=2) + "\n"
    if path.exists() and path.read_text() == content:
        print("Docker log defaults already configured.")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    existing = path.stat() if path.exists() else None
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".daemon-")
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        if existing:
            os.chown(temporary, existing.st_uid, existing.st_gid)
        os.chmod(temporary, stat.S_IMODE(existing.st_mode) if existing else 0o644)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
    print("Docker log defaults written. A running daemon needs a planned restart;")
    print("existing containers need recreation to inherit these defaults.")


if __name__ == "__main__":
    configure(Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/etc/docker/daemon.json"))
