FROM pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime

RUN apt-get update -qq && \
    apt-get install -y -qq curl fonts-dejavu-core > /dev/null 2>&1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -q transformers torchaudio huggingface_hub requests Pillow assemblyai

RUN curl -sL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz && \
    cd /tmp && tar xf ffmpeg.tar.xz && \
    cp /tmp/ffmpeg-*-amd64-static/ffmpeg /usr/local/bin/ffmpeg && \
    cp /tmp/ffmpeg-*-amd64-static/ffprobe /usr/local/bin/ffprobe && \
    rm -rf /tmp/ffmpeg*

RUN python3 -c "from huggingface_hub import snapshot_download; snapshot_download('openai/clip-vit-large-patch14')"

WORKDIR /workspace
