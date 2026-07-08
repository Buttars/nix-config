# TODO: create buttars-skills repo
{ inputs, ... }:
{
  flake-file.inputs = {
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    # buttars-skills = {
    #   url = "github:Buttars/skills";
    #   flake = false;
    # };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    anexpn-nixxx-shell = {
      url = "github:anexpn/nixxx-shell";
      flake = false;
    };
  };

  aegix.ai._.skills.homeManager =
    { ... }:
    {
      imports = [ inputs.agent-skills.homeManagerModules.default ];

      programs.agent-skills = {
        enable = true;

        # sources.buttars = {
        #   input = "buttars-skills";
        #   subdir = "skills";
        # };

        sources.matt = {
          path = inputs.mattpocock-skills;
          subdir = "skills";
          idPrefix = "matt";
        };

        sources.anexpn = {
          path = inputs.anexpn-nixxx-shell;
          subdir = ".claude/skills";
          idPrefix = "anexpn";
        };

        skills.enableAll = true;

        targets.kiro = {
          enable = true;
          dest = "$HOME/.kiro/skills";
          structure = "symlink-tree";
        };

        targets.claude = {
          enable = true;
        };

        targets.agents = {
          enable = true;
        };
      };
    };
}
