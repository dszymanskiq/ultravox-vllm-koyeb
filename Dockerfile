FROM vllm/vllm-openai:v0.21.0

ENV HF_HOME=/data/hf_cache
ENV HUGGINGFACE_HUB_CACHE=/data/hf_cache
ENV MODEL_NAME=fixie-ai/ultravox-v0_6-llama-3_1-8b
ENV MAX_MODEL_LEN=8192
ENV PORT=8000

EXPOSE 8000

ENTRYPOINT ["sh", "-c", \
  "python3 -m vllm.entrypoints.openai.api_server \
  --model $MODEL_NAME \
  --max-model-len $MAX_MODEL_LEN \
  --host 0.0.0.0 \
  --port $PORT \
  --trust-remote-code"]
