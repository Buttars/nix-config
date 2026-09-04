{
  default = "qwen2.5-coder:7b";

  # contextLength is what opencode is told; ollama must be serving at least
  # this much or the excess is silently truncated.
  # tools = false keeps a model out of opencode, which cannot drive a model
  # whose ollama template has no tool-calling support.
  models = {
    "qwen2.5-coder:7b" = {
      contextLength = 32768;
      tools = true;
    };
    "ornith:9b" = {
      contextLength = 32768;
      tools = false;
    };
    "hermes3:8b" = {
      contextLength = 32768;
      tools = true;
    };
    "huihui_ai/qwen3-abliterated:14b" = {
      contextLength = 32768;
      tools = true;
    };
    "huihui_ai/gemma3-abliterated:latest" = {
      contextLength = 32768;
      tools = false;
    };
    "unsloth/gemma-4-12b-it-GGUF" = {
      contextLength = 32768;
      tools = false;
    };
  };
}
