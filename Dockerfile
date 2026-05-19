FROM vllm/vllm-openai:nightly

ENV HF_HOME=/data/hf_cache
ENV HUGGINGFACE_HUB_CACHE=/data/hf_cache
ENV MODEL_NAME=fixie-ai/ultravox-v0_7-glm-4_6
ENV MAX_MODEL_LEN=8192
ENV PORT=8000

EXPOSE 8000

ENTRYPOINT ["sh", "-c", \
  "python3 -m vllm.entrypoints.openai.api_server \
  --model $MODEL_NAME \
  --max-model-len $MAX_MODEL_LEN \
  --host 0.0.0.0 \
  --port $PORT \
  --trust-remote-code \
  --quantization bitsandbytes \
  --load-format bitsandbytes"]
