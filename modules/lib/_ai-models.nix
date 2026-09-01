{
  default = "qwen2.5-coder:7b";

  # contextLength is what opencode is told; ollama must be serving at least
  # this much or the excess is silently truncated.
  models = {
    "qwen2.5-coder:7b".contextLength = 32768;
    "ornith:9b".contextLength = 32768;
    "hermes3:8b".contextLength = 32768;
    "huihui_ai/qwen3-abliterated:14b".contextLength = 32768;
    "huihui_ai/gemma3-abliterated:latest".contextLength = 32768;
  };
}
