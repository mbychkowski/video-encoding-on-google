#!/bin/bash -x

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Report start.
echo "`date`: ********* START $0 SRT CAPTURE SETUP *********"

# Install ffmpeg.
echo "`date`: ********* INSTALLING FFMPEG *********"

apt update
apt install -y ffmpeg
apt install -y \
  libaom-dev \
  libass-dev \
  libfdk-aac-dev \
  libnuma-dev \
  libopus-dev \
  libvorbis-dev \
  libvpx-dev \
  libx264-dev \
  libx265-dev \
  nasm \
  unzip

# Query Project metadata for Gateway IP and port.
GATEWAY_IP=$(curl -sX GET http://metadata.google.internal/computeMetadata/v1/project/attributes/gateway_ip -H 'Metadata-Flavor: Google')
CAPTURE_PORT=$(curl -sX GET http://metadata.google.internal/computeMetadata/v1/project/attributes/capture_port -H 'Metadata-Flavor: Google')

# Define SRT source.
SRT_SOURCE="srt://${GATEWAY_IP}:${CAPTURE_PORT}?pkt_size=1316&mode=caller&nakreport=1"

# Define output location and naming.
# For OUTPUT_PAD, use double-% to accommodate second_level_segment_index.
STRFTIME="%Y%m%dt%H%M%S"
OUTPUT_DIR=/tmp
OUTPUT_BASE="streamChunk"
OUTPUT_PAD="%%06d" 
OUTPUT_EXT="ts"
PLAYLIST_EXT="m3u8"
RESOLUTION="1080"

# Query which AVX are present on the chip. Use avx512 if present.
lscpu | grep -q avx512
[[ $? = 0 ]] && _ASM="avx512" || _ASM="avx2"

# Report ffmpeg start.
echo "`date`: ********* START $0 SRT CAPTURE *********"

# Construct ffmpeg and args.
ffmpeg \
  -i $SRT_SOURCE \
  -loglevel info \
  -y \
  -c:v libx264 \
  -filter:v scale="-2:$RESOLUTION" \
  -preset:v medium \
  -x264-params "keyint=120:min-keyint=120:sliced-threads=0:scenecut=0:asm=${_ASM}" \
  -tune psnr -profile:v high -b:v 6M -maxrate 12M -bufsize 24M \
  -c:a copy \
  -reset_timestamps 1 \
  -sc_threshold 0 \
  -force_key_frames "expr:gte(t, n_forced * 3.2)" \
  -strftime 1 \
  -hls_time "3.2" \
  -hls_list_size 0 \
  -hls_playlist_type event \
  -hls_flags second_level_segment_index \
  -f hls \
  -hls_playlist 0 \
  -hls_segment_filename "$OUTPUT_DIR/$OUTPUT_BASE-$STRFTIME-$OUTPUT_PAD.$OUTPUT_EXT" \
  $OUTPUT_DIR/$OUTPUT_BASE.$PLAYLIST_EXT

# Report end.
echo "`date`: ********* END $0 SRT CAPTURE *********"
