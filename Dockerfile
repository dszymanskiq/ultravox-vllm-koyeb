FROM vllm/vllm-openai:v0.21.0

RUN pip install bitsandbytes>=0.49.0 --no-deps -q

# Patch vLLM Ultravox WeightsMapper dla Qwen3-32B backbone
RUN python3 - <<'EOF'
import re, pathlib

p = pathlib.Path("/usr/local/lib/python3.12/dist-packages/vllm/model_executor/models/ultravox.py")
if not p.exists():
    import glob
    matches = glob.glob("/usr/local/lib/python*/dist-packages/vllm/model_executor/models/ultravox.py")
    p = pathlib.Path(matches[0]) if matches else None

if p:
    txt = p.read_text()
    old = '''hf_to_vllm_mapper = WeightsMapper(
    orig_to_new_prefix={
        "audio_tower.model.encoder.": "audio_tower.",
    }
)'''
    new = '''hf_to_vllm_mapper = WeightsMapper(
    orig_to_new_prefix={
        "audio_tower.model.encoder.": "audio_tower.",
        "model.": "language_model.model.",
        "lm_head.": "language_model.lm_head.",
    }
)'''
    if old in txt:
        p.write_text(txt.replace(old, new))
        print("Patch applied")
    elif "language_model.model." in txt:
        print("Already patched")
    else:
        print("WARNING: pattern not found, manual patch needed")
EOF

ENV HF_HOME=/data/hf_cache
ENV HUGGINGFACE_HUB_CACHE=/data/hf_cache
ENV MODEL_NAME=fixie-ai/ultravox-v0_6-qwen-3-32b
ENV MAX_MODEL_LEN=8192
ENV PORT=8000
ENV VLLM_USE_FLASHINFER_SAMPLER=0

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
