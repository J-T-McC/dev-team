#!/usr/bin/env python3
"""Render templates/board.html with sample data, outside claude.ai: a stand-in for claude.use("db") serves it.

Usage: tests/board-preview.py <out.html> [light|dark] [sample.json]
Used by tests/board.sh and for the README screenshots (examples/board/).
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
out, theme = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "light")
sample = json.loads(Path(sys.argv[3] if len(sys.argv) > 3 else ROOT / "examples/board/sample.json").read_text())
page = (ROOT / "templates/board.html").read_text().replace("{{PROJECT}}", "Acme")

stub = """<script>
const SAMPLE = %s;
SAMPLE["meta/board"] = { updated: new Date(Date.now() - 3 * 60000).toISOString() };
const snap = (r) => ({ id: r.id, data: () => r });
window.claude = { use: async (name) => name !== "db" ? null : {
  collection: (c) => ({ onSnapshot: (next) => { setTimeout(() => next({ docs: (SAMPLE[c] || []).map(snap) })); return () => {}; } }),
  doc: (p) => ({ onSnapshot: (next) => { setTimeout(() => next({ exists: p in SAMPLE, data: () => SAMPLE[p] })); return () => {}; } }),
} };
</script>""" % json.dumps(sample)

Path(out).write_text(f'<!doctype html><html data-theme="{theme}"><head><meta charset="utf-8">'
                     f'<meta name="viewport" content="width=device-width,initial-scale=1"></head><body>'
                     f"{stub}{page}</body></html>")
