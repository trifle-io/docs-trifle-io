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

### Claude Code

```sh
/plugin marketplace add trifle-io/skills
/plugin install trifle-stats@trifle-io/skills
/plugin install trifle-traces@trifle-io/skills
/plugin install trifle-cli@trifle-io/skills
```

Or copy skill directories into your project:

```sh
cp -r trifle-stats .claude/skills/
cp -r trifle-traces .claude/skills/
cp -r trifle-cli .claude/skills/
```

### OpenAI Codex

Install skills into your Codex skills directory:

```sh
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME/skills"
cp -R trifle-stats "$CODEX_HOME/skills/trifle-stats"
cp -R trifle-traces "$CODEX_HOME/skills/trifle-traces"
cp -R trifle-cli "$CODEX_HOME/skills/trifle-cli"
```

### Cursor

```sh
cp trifle-stats/SKILL.md .cursor/rules/trifle-stats.mdc
cp trifle-traces/SKILL.md .cursor/rules/trifle-traces.mdc
cp trifle-cli/SKILL.md .cursor/rules/trifle-cli.mdc
```

### Any other agent

These skills follow the [Agent Skills](https://agentskills.io) open standard. Each skill is a `SKILL.md` file with YAML frontmatter and markdown instructions. Copy the content into whatever custom instructions mechanism your agent supports.

## Source

Skills are open source at [github.com/trifle-io/skills](https://github.com/trifle-io/skills).
