# AS Tools — Setup Guide

Pathology lab workflow tools, distributed via Homebrew.
No Python, Node.js, or GitHub account required — `brew install` handles everything.

**Only prerequisite:** [Homebrew](https://brew.sh) installed on the Mac.

---

## Table of Contents

1. [Step-by-step setup](#step-by-step-setup)
2. [What gets installed](#what-gets-installed)
3. [Available commands](#available-commands)
4. [Command reference](#command-reference)
5. [Terminal theme (optional)](#terminal-theme-optional)
6. [Verifying the installation](#verifying-the-installation)
7. [Day-to-day usage](#day-to-day-usage)
8. [Updating](#updating)
9. [Uninstalling](#uninstalling)
10. [Troubleshooting](#troubleshooting)

---

## Step-by-step setup

Open **Terminal.app** (Applications → Utilities → Terminal) and run the following
commands one at a time. Each step is explained below.

### Step 1 — Verify Homebrew

Confirm Homebrew is installed and working:

```bash
brew --version
```

You should see something like `Homebrew 4.x.x`. If not, install Homebrew first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

If Homebrew was just installed, follow the on-screen instructions to add it to your
PATH (the installer will print the exact commands for your Mac — Intel vs Apple Silicon).

### Step 2 — Add the AS Tools tap

A "tap" tells Homebrew where to find our custom formula:

```bash
brew tap aggelosskodras/as-tools
```

### Step 3 — Install AS Tools

This single command installs Python 3.12, Node.js, Tcl/Tk, all 8 tools, and creates
isolated virtual environments for each Python tool:

```bash
brew install as-tools
```

This takes a few minutes on first install (downloading runtimes + building venvs).

When it finishes, Homebrew will print a **Caveats** section — follow the instructions
in Steps 4 and 5 below.

### Step 4 — Add shell integration to your profile

This adds the `as-tools` help command and shell functions to every new Terminal session:

```bash
echo 'source "$(brew --prefix)/share/as-tools/as-tools.sh"' >> ~/.zshrc
```

### Step 5 — Reload your shell

Apply the changes to your current Terminal window:

```bash
source ~/.zshrc
```

### Step 6 — Verify

Run the help command to confirm everything is working:

```bash
as-tools
```

You should see a formatted table listing all 9 available commands.

### Step 7 (optional) — Import the dark terminal theme

```bash
as-tools-theme
```

Terminal.app will open a new window with the **AS-Dark** profile.
To make it your default:

1. Go to **Terminal → Settings → Profiles**
2. Select **AS-Dark** in the left sidebar
3. Click **Default** at the bottom

The theme provides a Dracula-inspired dark colour scheme with a full 16-colour
ANSI palette optimised for syntax highlighting in terminal tools.

---

## What gets installed

`brew install as-tools` installs the following automatically:

| Component | What | Why |
|-----------|------|-----|
| `python@3.12` | Python 3.12 runtime | Runs 6 of the 8 tools |
| `node` | Node.js runtime | Runs assign (Case Orchestrator) and lis (LIS Mock) |
| `tcl-tk` | Tcl/Tk GUI framework | Required by users_creation GUI |
| 6 Python venvs | Isolated virtual environments | One per Python tool, each with its own pip dependencies |
| 9 wrapper scripts | Executables in Homebrew's `bin/` | `filter`, `slide_labeler`, `assign`, `unmatch`, `consult`, `lis`, `users_creation`, `users_creation_gui`, `dashboard` |
| `as-tools` | Help command | Lists all commands with descriptions |
| `as-tools-theme` | Theme importer | Imports the AS-Dark Terminal.app profile |
| `as-tools.sh` | Shell integration | Sourced from `~/.zshrc` for help command and functions |
| `AS-Dark.terminal` | Terminal.app profile | Dark high-contrast theme with syntax highlighting colours |

All tool sources and venvs live under Homebrew's `libexec/` — nothing is installed
globally and nothing conflicts with other software on the Mac.

---

## Available commands

After installation, these commands are available system-wide from any Terminal window:

| Command | Tool | Type | Port |
|---------|------|------|------|
| `filter` | Filter Push TUI | Terminal UI | — |
| `slide_labeler` | Slide Labeler | CLI | — |
| `assign` | Case Orchestrator | Web UI | 3002 |
| `unmatch` | Unmatch Images TUI | Terminal UI | — |
| `consult` | ConsultHub | Web UI (Streamlit) | 8501 |
| `lis` | LIS Mock Server | Web server | 3000 |
| `users_creation` | User Creation | CLI | — |
| `users_creation_gui` | User Creation | Desktop GUI | — |
| `dashboard` | Pathology Audit Dashboard | Web UI (Streamlit) | 8502 |

Plus two utility commands:

| Command | Description |
|---------|-------------|
| `as-tools` | Show help with all available commands |
| `as-tools-theme` | Import the AS-Dark Terminal.app profile |

---

## Command reference

### `filter` — Filter Push TUI

Push analysis filters to Concentriq user groups via a terminal interface.

```bash
filter              # launch the TUI
filter --help       # show options
```

**Runtime:** Python 3.12 + Textual
**Dependencies:** textual, requests

---

### `slide_labeler` — Slide Labeler

Batch-label slides with QR codes and metadata via S3/Concentriq.

```bash
slide_labeler           # launch with auto mode
slide_labeler --help    # show options
```

**Runtime:** Python 3.12 + Click
**Dependencies:** boto3, botocore, requests, click, PyYAML, Pillow, qrcode, psycopg2-binary

---

### `assign` — Case Orchestrator

Assign and balance pathology cases across pathologists.
Opens a web UI in your browser.

```bash
assign              # start server and open browser at http://localhost:3002
assign --help       # show options
```

Press `Ctrl+C` to stop the server.

**Runtime:** Node.js + Next.js 16
**Port:** 3002

---

### `unmatch` — Unmatch Images TUI

Review and unmatch incorrectly paired slide images via a terminal interface.

```bash
unmatch             # launch the TUI
```

**Runtime:** Python 3.12 + Textual
**Dependencies:** textual

---

### `consult` — ConsultHub

Consultation management with slide upload and orchestration.
Opens a Streamlit web app in your browser.

```bash
consult             # start server at http://localhost:8501
```

Press `Ctrl+C` to stop the server.

**Runtime:** Python 3.12 + Streamlit
**Port:** 8501
**Dependencies:** streamlit, pandas, requests

---

### `lis` — LIS Mock Server

Simulate a Laboratory Information System for testing and development.

```bash
lis                 # start server at http://localhost:3000
```

Press `Ctrl+C` to stop the server.

**Runtime:** Node.js (pure — no npm dependencies)
**Port:** 3000

---

### `users_creation` — User Creation (CLI)

Batch-create Concentriq LS users from spreadsheets, command-line interface.

```bash
users_creation          # launch CLI
users_creation --help   # show options
```

**Runtime:** Python 3.12
**Dependencies:** requests, pandas, customtkinter

---

### `users_creation_gui` — User Creation (GUI)

Same as `users_creation` but with a graphical desktop interface (CustomTkinter).

```bash
users_creation_gui      # launch GUI window
```

**Runtime:** Python 3.12 + CustomTkinter + Tcl/Tk

---

### `dashboard` — Pathology Audit Dashboard

Pathology audit trail analytics with DuckDB and Plotly visualisations.
Opens a Streamlit web app in your browser.

```bash
dashboard           # start server at http://localhost:8502
```

Press `Ctrl+C` to stop the server.

**Runtime:** Python 3.12 + Streamlit
**Port:** 8502
**Dependencies:** streamlit, duckdb, pandas, pyarrow, plotly

---

## Terminal theme (optional)

The bundled **AS-Dark** profile is a dark high-contrast theme designed for
readability in terminal tools. It does not override your current default profile.

**Colour palette (Dracula-inspired):**

| Colour | Normal | Bright |
|--------|--------|--------|
| Black | `#21222c` | `#6272a4` |
| Red | `#ff5555` | `#ff6e6e` |
| Green | `#50fa7b` | `#69ff94` |
| Yellow | `#f1fa8c` | `#ffffa5` |
| Blue | `#6272a4` | `#d6acff` |
| Magenta | `#ff79c6` | `#ff92df` |
| Cyan | `#8be9fd` | `#a4ffff` |
| White | `#f8f8f2` | `#ffffff` |

**Additional colours:**
- Background: `#1a1a2e` (deep dark blue-grey)
- Foreground: `#e0e0e0` (near-white)
- Bold text: `#ffffff` (pure white)
- Cursor: `#00d4aa` (teal)
- Selection: `#3a3a5c` (muted purple)

**Font:** Menlo Regular 13pt
**Window:** 120 columns x 35 rows

To import:

```bash
as-tools-theme
```

Then: **Terminal → Settings → Profiles → AS-Dark → Default**

---

## Verifying the installation

After completing all setup steps, run through this checklist to confirm
everything works:

```bash
# 1. Help command works
as-tools

# 2. All commands are on PATH
which filter slide_labeler assign unmatch consult lis users_creation users_creation_gui dashboard

# 3. Python tools respond to --help
filter --help
slide_labeler --help
users_creation --help

# 4. Runtimes installed
python3.12 --version
node --version

# 5. Theme file exists
ls "$(brew --prefix)/share/as-tools/AS-Dark.terminal"
```

All 5 checks should pass without errors.

---

## Day-to-day usage

### Terminal UI tools (filter, unmatch)

These run directly in your Terminal window. Navigate with keyboard. Press `q` or
`Ctrl+C` to exit.

```bash
filter          # opens TUI in current terminal
unmatch         # opens TUI in current terminal
```

### CLI tools (slide_labeler, users_creation)

These run as standard command-line programs. Use `--help` for options.

```bash
slide_labeler --help
users_creation --help
```

### Web-based tools (assign, consult, lis, dashboard)

These start a local web server. Your browser opens automatically (or open the
URL manually). Press `Ctrl+C` in the Terminal to stop the server.

```bash
assign          # http://localhost:3002
consult         # http://localhost:8501
lis             # http://localhost:3000
dashboard       # http://localhost:8502
```

### GUI tools (users_creation_gui)

Opens a native desktop window.

```bash
users_creation_gui
```

---

## Updating

When a new version is released:

```bash
brew update
brew upgrade as-tools
```

---

## Uninstalling

```bash
brew uninstall as-tools
```

Optionally remove the shell integration line from `~/.zshrc`:

```bash
# Open ~/.zshrc in a text editor and remove the line:
#   source "$(brew --prefix)/share/as-tools/as-tools.sh"
nano ~/.zshrc
```

Optionally remove the Terminal theme:
**Terminal → Settings → Profiles → AS-Dark → click "..." → Delete**

---

## Troubleshooting

### "command not found" after install

**Cause:** The shell integration line was not added, or the shell was not reloaded.

```bash
# Check if the line is in your profile
grep "as-tools" ~/.zshrc

# If missing, add it
echo 'source "$(brew --prefix)/share/as-tools/as-tools.sh"' >> ~/.zshrc

# Reload
source ~/.zshrc
```

### "command not found" for `brew`

**Cause:** Homebrew is not on PATH. This can happen on Apple Silicon Macs where
Homebrew installs to `/opt/homebrew/` instead of `/usr/local/`.

```bash
# Apple Silicon Mac (M1/M2/M3/M4)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Python or Node errors

Try a clean reinstall:

```bash
brew reinstall as-tools
```

### Port already in use

Another process is using the port. Find and stop it:

```bash
# Example: find what's using port 3002
lsof -i :3002
# Kill it (replace PID with the actual process ID)
kill PID
```

### "Permission denied" when running a command

```bash
# Verify wrapper scripts are executable
ls -la "$(brew --prefix)/bin/filter"
# Should show -rwxr-xr-x permissions

# If needed, fix permissions
chmod +x "$(brew --prefix)/bin/"filter slide_labeler assign unmatch consult lis users_creation users_creation_gui dashboard
```

### Streamlit tools show a blank page

Streamlit defaults to opening `localhost` in the browser. If it shows blank:

1. Wait a few seconds — Streamlit needs time to start
2. Try manually opening the URL printed in the Terminal
3. Check that no firewall is blocking local connections

### GUI tool (users_creation_gui) doesn't open a window

**Cause:** Tcl/Tk may not be linked correctly.

```bash
brew reinstall tcl-tk
brew reinstall as-tools
```

---

## Quick reference card

```
SETUP (one-time)
  brew tap aggelosskodras/as-tools
  brew install as-tools
  echo 'source "$(brew --prefix)/share/as-tools/as-tools.sh"' >> ~/.zshrc
  source ~/.zshrc

DAILY USE
  as-tools                  show help
  filter                    push filters (TUI)
  slide_labeler             label slides (CLI)
  assign                    assign cases (web :3002)
  unmatch                   unmatch images (TUI)
  consult                   consultation hub (web :8501)
  lis                       LIS mock server (web :3000)
  users_creation            create users (CLI)
  users_creation_gui        create users (GUI)
  dashboard                 audit dashboard (web :8502)

MAINTENANCE
  brew update && brew upgrade as-tools    update
  brew uninstall as-tools                 remove

THEME
  as-tools-theme            import dark Terminal profile
```
