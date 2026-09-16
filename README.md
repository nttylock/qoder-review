# qoder-review

An agent skill that runs **Qoder CLI code review + security audit** locally — no GitHub Actions, no posted comments, no code changes. Review a pull request or your current working tree and get two Markdown reports back.

Same two report surfaces, two ways to run:

| Mode | Where | Auth | Output |
| --- | --- | --- | --- |
| Local skill | Your agent (Claude Code, Cursor, Windsurf, Codex, Devin, …) | `qodercli login` session | Markdown in chat |
| GitHub Action | CI on every PR | `QODER_PERSONAL_ACCESS_TOKEN` secret | PR comments |

## What it does

- **Code review** — correctness, security, performance, tests, maintainability, project conventions
- **Security audit** — authn/authz, injection, SSRF, path traversal, secrets, unsafe parsing/execution, API security, crypto, races/TOCTOU, prompt-injection risks. Runs only when security-relevant files changed.
- Diff is passed via stdin inside `<untrusted_diff>` tags, tools are disabled (`--tools ""`), `dont_ask` permission mode — the model can only read the diff and return a report.
- Caps: 100 KB diff, 50 files in the file list.
- Read-only: never edits files, never posts GitHub comments.

## Prerequisites

- [Qoder CLI](https://qoder.com) installed and on `PATH` as `qodercli`
- `git`, `bash`
- `gh` (GitHub CLI) — only for PR-number mode
- macOS/Linux shell (works anywhere `qodercli` runs)

**Local auth:** run `qodercli login` once and finish browser authorization. The skill uses that local session (`~/.qoder/`) — no API key, no env var. The script checks auth with `qodercli --list-models` and tells you to log in if the session is missing.

## Install

### One-liner (skills CLI)

```bash
npx skills add nttylock/qoder-review
```

### Manual

Copy this directory into your agent's skills folder as `qoder-review/`:

| Agent | Path |
| --- | --- |
| Claude Code | `~/.claude/skills/qoder-review/` |
| Cursor (global) | `~/.cursor/skills/qoder-review/` |
| Cursor (project) | `<repo>/.cursor/skills/qoder-review/` |
| Windsurf | `~/.codeium/windsurf/skills/qoder-review/` |
| Generic agents | `~/.agents/skills/qoder-review/` |

```bash
git clone https://github.com/nttylock/qoder-review.git /tmp/qoder-review
mkdir -p ~/.agents/skills/qoder-review
cp -R /tmp/qoder-review/SKILL.md /tmp/qoder-review/scripts /tmp/qoder-review/agents ~/.agents/skills/qoder-review/
```

## Usage

Invoke the skill (`$qoder-review`, `/qoder-review`, or just ask your agent for a "qoder review"), or run the script directly from anywhere inside a git repo:

```bash
# Review a GitHub PR (read-only, does not post comments)
scripts/qoder-review.sh 1530

# Review current branch + tracked working-tree changes vs origin/main
scripts/qoder-review.sh current
```

Optional env overrides (only when you explicitly want them):

- `QODER_REVIEW_BASE` — base ref for `current` mode (default `origin/main`)
- `QODER_REVIEW_MODEL` — Qoder model (default `Qwen3.8-Max`)

Note: `current` mode covers **tracked** files only; untracked files are excluded (a warning is printed).

## GitHub Action

`github-actions/qoder-code-review.yml` runs the same two reports on every PR and posts them as comments (old Qoder comments are cleaned up first).

Setup:

1. Copy `github-actions/qoder-code-review.yml` → `<your-repo>/.github/workflows/`
2. Repo → Settings → Secrets → add `QODER_PERSONAL_ACCESS_TOKEN` (from your Qoder account)
3. Open a PR — two jobs run: `Qoder Code Review` and `Qoder Security Audit`

## Development

```bash
bash scripts/qoder-review.test.sh   # contract checks: usage exit code, stdin prompt
```

## License

MIT
