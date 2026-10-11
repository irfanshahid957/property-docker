FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

# 1. NVENC + GPU rendering environment
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,graphics
ENV DEBIAN_FRONTEND=noninteractive

# 2. System packages — apt ffmpeg has NVENC headers (works when GPU driver available)
RUN apt-get update -qq && \
    apt-get install -y -qq curl fonts-dejavu-core ffmpeg xz-utils > /dev/null 2>&1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Pip dependencies
RUN pip install --no-cache-dir -q transformers torchaudio huggingface_hub requests Pillow assemblyai

# 4. OpenAI CLIP model (public, no token needed)
RUN python3 -c "from huggingface_hub import snapshot_download; snapshot_download('openai/clip-vit-large-patch14')"

# 5. HuggingFace private model (optional — skips if HF_TOKEN not available)
RUN --mount=type=secret,id=HF_TOKEN \
    if [ -f /run/secrets/HF_TOKEN ] && [ -s /run/secrets/HF_TOKEN ]; then \
      export HF_TOKEN=$(cat /run/secrets/HF_TOKEN) && \
      python3 -c "import os; from transformers import pipeline; pipeline('image-classification', model='irfanshahid957/real-estate-classifier', token=os.environ['HF_TOKEN'])" && \
      find /root/.cache/huggingface -name '*.lock' -delete && \
      echo 'ViT classifier downloaded'; \
    else \
      echo 'HF_TOKEN not found, skipping classifier download'; \
    fi

WORKDIR /workspace
