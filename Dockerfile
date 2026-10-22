FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,graphics
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y -qq python3 python3-pip curl fonts-dejavu-core ffmpeg xz-utils unzip > /dev/null 2>&1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Python packages (pip3 install without --break-system-packages for Ubuntu 22.04 / Python 3.10)
RUN pip3 install --no-cache-dir -q Pillow requests assemblyai yt-dlp yt-dlp-ejs ddgs

# Deno runtime (required for yt-dlp-ejs, node is unsupported)
RUN curl -fsSL https://deno.land/install.sh | sh && \
    ln -sf /root/.deno/bin/deno /usr/local/bin/deno

WORKDIR /workspace
