# frozen_string_literal: true

# Homebrew formula for AS Tools
# Install: brew tap aggelosskodras/as-tools && brew install as-tools
class AsTools < Formula
  desc "Pathology lab workflow tools: filter, assign, unmatch, consult, dashboard & more"
  homepage "https://github.com/aggelosskodras/homebrew-as-tools"
  url "https://github.com/aggelosskodras/homebrew-as-tools/releases/download/v0.2.0/as-tools-0.2.0.tar.gz"
  sha256 "4acb5771380556af077ebb6b11c938919caa31591ff101d86fbe9f10253c4f91"
  license "MIT"
  version "0.2.0"

  depends_on "python@3.12"
  depends_on "node"
  # tcl-tk only needed if users_create uses tkinter file picker on first run
  depends_on "tcl-tk" => :recommended

  def install
    # ---------------------------------------------------------------
    # 1. Copy all tool sources into libexec/
    # ---------------------------------------------------------------
    libexec.install Dir["*"]

    # ---------------------------------------------------------------
    # 2. Python venvs — one per tool for isolation
    # ---------------------------------------------------------------
    python = Formula["python@3.12"].opt_bin/"python3.12"

    python_tools = {
      "filter" => {
        dir: "filter",
        deps: %w[textual requests],
        entry: "filter_push_tui.py",
        cli_args: "",
      },
      "unmatch" => {
        dir: "unmatch",
        deps: %w[textual],
        entry: "unmatch_images_tui.py",
        cli_args: "",
      },
      "consult" => {
        dir: "consult",
        deps: %w[streamlit pandas requests],
        entry: "-m streamlit run Home.py",
        cli_args: "--server.port 8501",
      },
      "users_create" => {
        dir: "users_create",
        deps: %w[pandas requests openpyxl],
        entry: "AS-Create-Users-AP-Dx.py",
        cli_args: "",
      },
      "users_create_LS" => {
        dir: "users_create_LS/user-creation",
        deps: %w[requests pandas],
        entry: "src/cli.py",
        cli_args: "",
      },
      "dashboard" => {
        dir: "dashboard",
        deps: %w[streamlit duckdb pandas pyarrow plotly],
        entry: "-m streamlit run dashboard/app.py",
        cli_args: "--server.port 8502",
      },
    }

    python_tools.each do |cmd, spec|
      tool_dir = libexec/spec[:dir]
      venv_dir = tool_dir/".brew_venv"

      # Create venv
      system python, "-m", "venv", venv_dir
      venv_pip = venv_dir/"bin/pip"
      system venv_pip, "install", "--quiet", "--upgrade", "pip"
      system venv_pip, "install", "--quiet", *spec[:deps] unless spec[:deps].empty?

      # Generate wrapper script
      venv_python = venv_dir/"bin/python"
      (bin/cmd).write <<~BASH
        #!/usr/bin/env bash
        # AS Tools wrapper: #{cmd}
        cd "#{tool_dir}" || exit 1
        exec "#{venv_python}" #{spec[:entry]} #{spec[:cli_args]} "$@"
      BASH
      chmod 0755, bin/cmd
    end

    # ---------------------------------------------------------------
    # 3. Node.js tools
    # ---------------------------------------------------------------

    # assign (Case Orchestrator — Next.js)
    assign_dir = libexec/"assign/app"
    cd assign_dir do
      system "npm", "install", "--production=false"
      system "npm", "run", "build"
    end
    (bin/"assign").write <<~BASH
      #!/usr/bin/env bash
      # AS Tools wrapper: assign (Case Orchestrator)
      TOOL_DIR="#{libexec}/assign"
      if [ -f "$TOOL_DIR/assign.sh" ]; then
        cd "$TOOL_DIR" && exec bash assign.sh "$@"
      else
        cd "$TOOL_DIR/app" && exec npm run dev "$@"
      fi
    BASH
    chmod 0755, bin/"assign"

    # lis (LIS Mock Server — pure Node.js)
    (bin/"lis").write <<~BASH
      #!/usr/bin/env bash
      # AS Tools wrapper: lis (LIS Mock Server)
      TOOL_DIR="#{libexec}/lis"
      echo "Starting LIS Mock Server on http://localhost:3000 ..."
      cd "$TOOL_DIR" && exec node server.js "$@"
    BASH
    chmod 0755, bin/"lis"

    # ---------------------------------------------------------------
    # 4. Shell integration + theme -> share/
    # ---------------------------------------------------------------
    (share/"as-tools").install libexec/"shell/as-tools.sh"
    (share/"as-tools").install libexec/"theme/AS-Dark.terminal"
    (share/"as-tools").install libexec/"README.md"

    # ---------------------------------------------------------------
    # 5. Help command wrapper
    # ---------------------------------------------------------------
    (bin/"as-tools").write <<~BASH
      #!/usr/bin/env bash
      # AS Tools — master help command
      source "#{share}/as-tools/as-tools.sh"
      __as_tools_help
    BASH
    chmod 0755, bin/"as-tools"

    # ---------------------------------------------------------------
    # 6. Theme import helper
    # ---------------------------------------------------------------
    (bin/"as-tools-theme").write <<~BASH
      #!/usr/bin/env bash
      # Import AS-Dark Terminal.app theme
      THEME="#{share}/as-tools/AS-Dark.terminal"
      if [ -f "$THEME" ]; then
        open "$THEME"
        echo "AS-Dark theme imported into Terminal.app."
        echo "Set it as default: Terminal → Settings → Profiles → AS-Dark → Default"
      else
        echo "Error: Theme file not found at $THEME" >&2
        exit 1
      fi
    BASH
    chmod 0755, bin/"as-tools-theme"
  end

  def caveats
    <<~EOS

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        AS Tools installed successfully!
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      1. Add shell integration to your ~/.zshrc:

         echo 'source "$(brew --prefix)/share/as-tools/as-tools.sh"' >> ~/.zshrc
         source ~/.zshrc

      2. Verify installation:

         as-tools

      3. Optional — import the dark Terminal theme:

         as-tools-theme

         Then set "AS-Dark" as default in Terminal → Settings → Profiles.

      Available commands: filter, assign, unmatch, consult,
        lis, users_create, users_create_LS, dashboard
    EOS
  end

  test do
    assert_match "AS Tools", shell_output("#{bin}/as-tools")
  end
end
