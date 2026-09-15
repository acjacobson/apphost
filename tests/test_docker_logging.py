import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/configure-docker-logging.py"
spec = importlib.util.spec_from_file_location("logging_config", SCRIPT)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LoggingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "docker/daemon.json"

    def seed(self, content):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(content)

    def test_defaults_and_idempotence(self):
        module.configure(self.path)
        self.assertEqual(json.loads(self.path.read_text()), {
            "log-driver": "json-file",
            "log-opts": {"max-size": "10m", "max-file": "3"},
        })
        before = self.path.stat().st_mtime_ns
        module.configure(self.path)
        self.assertEqual(self.path.stat().st_mtime_ns, before)

    def test_preserves_settings_and_mode(self):
        self.seed(json.dumps({"live-restore": True, "log-opts": {"max-size": "20m"}}))
        self.path.chmod(0o600)
        module.configure(self.path)
        config = json.loads(self.path.read_text())
        self.assertTrue(config["live-restore"])
        self.assertEqual(config["log-opts"], {"max-size": "20m", "max-file": "3"})
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)

    def test_preserves_other_driver(self):
        content = '{"log-driver": "journald"}\n'
        self.seed(content)
        module.configure(self.path)
        self.assertEqual(self.path.read_text(), content)

    def test_invalid_config_is_not_overwritten(self):
        for content in ("{broken", "[]", '{"log-opts": []}'):
            with self.subTest(content=content):
                self.seed(content)
                with self.assertRaises(ValueError):
                    module.configure(self.path)
                self.assertEqual(self.path.read_text(), content)


if __name__ == "__main__":
    unittest.main()
