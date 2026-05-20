---
title: Trifle Skills
description: Agent skills that teach AI coding agents how to use the Trifle ecosystem effectively.
nav_order: 2.5
svg: M4.26 10.147a60.438 60.438 0 0 0-.491 6.347A48.62 48.62 0 0 1 12 20.904a48.62 48.62 0 0 1 8.232-4.41 60.46 60.46 0 0 0-.491-6.347m-15.482 0a50.636 50.636 0 0 0-2.658-.813A59.906 59.906 0 0 1 12 3.493a59.903 59.903 0 0 1 10.399 5.84c-.896.248-1.783.52-2.658.814m-15.482 0A50.717 50.717 0 0 1 12 13.489a50.702 50.702 0 0 1 7.74-3.342M6.75 15a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Zm0 0v-3.675A55.378 55.378 0 0 1 12 8.443m-7.007 11.55A5.981 5.981 0 0 0 6.75 15.75v-1.5
---

# Trifle Skills

Agent skills for AI coding agents. Teach Claude Code, Codex, Cursor, and other agents how to use Trifle Stats, Trifle Traces, and Trifle CLI with best practices built in.

## What are skills?

Skills are structured instruction files that AI coding agents load when working on your codebase. Instead of explaining how Trifle works every time, install a skill and the agent knows how to structure values payloads, trace execution flow, and run CLI analytics — following the same patterns you'd use yourself.

## Available skills

| Skill | What it teaches |
|-------|----------------|
| **trifle-stats** | Time-series metrics in Ruby, Elixir, and Go. Values payload structure, dimensional tracking, duration with standard deviation, key splitting strategies, and the ~500 key performance ceiling. |
| **trifle-traces** | Structured execution tracing in Ruby. How to trace conditions, API calls, loops, and objects so the full execution flow is readable when you open a trace. |
| **trifle-cli** | Command-line metrics with local SQLite storage. Agent analytics workflows for tracking, querying, and iterating on metric structure. |

## Install

### npx (recommended)

Install all Trifle skills with npm/npx:

```sh
npx -y @trifle/skills install codex
```

Project-local agents use the current directory by default:

```sh
npx -y @trifle/skills install claude
npx -y @trifle/skills install cursor
npx -y @trifle/skills install windsurf
npx -y @trifle/skills install cline
```

Install a single skill with `--skill`:

```sh
npx -y @trifle/skills install codex --skill trifle-stats
```

Use `--dir` to install into a different project root. For Codex, `--dir` overrides `$CODEX_HOME`.

```sh
npx -y @trifle/skills install claude --dir /path/to/project
npx -y @trifle/skills install codex --dir /path/to/codex-home
```

The installer refuses to overwrite changed files. Re-run with `--force` when you want to replace an existing install:

```sh
npx -y @trifle/skills install codex --force
```

After installing, restart Codex to pick up new skills.

### Claude Code marketplace

```sh
/plugin marketplace add trifle-io/skills
/plugin install trifle-stats@trifle-io/skills
/plugin install trifle-traces@trifle-io/skills
/plugin install trifle-cli@trifle-io/skills
```

### Manual install

If you prefer not to use npx, copy the skill files from a checkout of [github.com/trifle-io/skills](https://github.com/trifle-io/skills).

#### OpenAI Codex

```sh
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME/skills"
cp -R trifle-stats/skills/trifle-stats "$CODEX_HOME/skills/trifle-stats"
cp -R trifle-traces/skills/trifle-traces "$CODEX_HOME/skills/trifle-traces"
cp -R trifle-cli/skills/trifle-cli "$CODEX_HOME/skills/trifle-cli"
```

#### Claude Code

```sh
mkdir -p .claude/skills
cp -r trifle-stats/skills/trifle-stats .claude/skills/
cp -r trifle-traces/skills/trifle-traces .claude/skills/
cp -r trifle-cli/skills/trifle-cli .claude/skills/
```

#### Cursor

```sh
mkdir -p .cursor/rules
cp trifle-stats/skills/trifle-stats/SKILL.md .cursor/rules/trifle-stats.mdc
cp trifle-traces/skills/trifle-traces/SKILL.md .cursor/rules/trifle-traces.mdc
cp trifle-cli/skills/trifle-cli/SKILL.md .cursor/rules/trifle-cli.mdc
```

#### Windsurf

```sh
mkdir -p .windsurf/rules
cp trifle-stats/skills/trifle-stats/SKILL.md .windsurf/rules/trifle-stats.md
cp trifle-traces/skills/trifle-traces/SKILL.md .windsurf/rules/trifle-traces.md
cp trifle-cli/skills/trifle-cli/SKILL.md .windsurf/rules/trifle-cli.md
```

#### Cline

```sh
mkdir -p .cline/skills
cp -r trifle-stats/skills/trifle-stats .cline/skills/
cp -r trifle-traces/skills/trifle-traces .cline/skills/
cp -r trifle-cli/skills/trifle-cli .cline/skills/
```

### Any other agent

These skills follow the [Agent Skills](https://agentskills.io) open standard. Each skill is a `SKILL.md` file with YAML frontmatter and markdown instructions. Copy the content into whatever custom instructions mechanism your agent supports.

## Source

Skills are open source at [github.com/trifle-io/skills](https://github.com/trifle-io/skills).
