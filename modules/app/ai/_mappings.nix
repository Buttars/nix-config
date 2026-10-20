# Translates the abstract vocabulary in _agents.nix into Kiro's concrete names.
# Everything harness-specific about tools, models, and MCP selection is confined
# to this file, so retargeting means writing a sibling rather than editing agents.
#
# Tool names were read from a live session rather than the published schema: the
# schema example lists `delegate` and `fs_read`, but this build answers with
# `subagent`, `read`, `grep`, and `glob`. V2 and V3 disagree on which spelling is
# canonical, so if an engine change breaks tool resolution, it breaks here only.
{
  # Included for every agent regardless of declared capabilities: without these
  # an agent cannot track its own work or report completion.
  baseTools = [
    "todo_list"
    "goal"
    "introspect"
    "knowledge"
  ];

  tools = {
    read = [ "read" ];
    search = [
      "grep"
      "glob"
    ];
    code = [ "code" ];
    edit = [ "write" ];
    shell = [ "shell" ];
    web = [
      "web_search"
      "web_fetch"
    ];
    spawn = [ "subagent" ];
    aws = [ "use_aws" ];
  };

  # Keyed to the tier names in _agents.nix. Multipliers from
  # `kiro-cli chat --list-models`: opus 2.20x, sonnet 1.30x.
  models = {
    strong = "claude-opus-5";
    fast = "claude-sonnet-5";
  };

  # Groups of _mcp.nix server names. Server definitions are the largest single
  # item in an agent's starting context, so these are assigned per agent rather
  # than handed out wholesale.
  mcp = {
    forge = [ "github" ];
    docs = [
      "context7"
      "nixos"
    ];
    tickets = [
      "atlassian"
      "servicenow"
    ];
    infra = [
      "docker"
      "kubernetes"
      "aws"
    ];
    flags = [ "launchdarkly" ];
    terminal = [ "tmux" ];
    files = [ "filesystem" ];
  };
}
