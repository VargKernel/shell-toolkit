#!/bin/bash

# ---DOC-START---
# summary: Download audio only as MP3 via yt-dlp.
# description: |
#   All three scripts share the same conventions: they install [jq](https://jqlang.github.io/jq/) and `wget` if missing, use Firefox cookies and a Node.js JS runtime for restricted videos, and retry up to 100 times with randomized sleep intervals. Output filenames always include uploader, upload date, title, and video ID. No root required.
#
#   - Usage: `./yt-dlp-audio-only.sh <URL> [extra yt-dlp options]`
#   - Extracts audio at the best available quality (`--audio-quality 0`) and converts to MP3
# sudo: true
# interactive: false
# idempotent: true
# ---DOC-END---

set -euo pipefail

echo "[*] Installing required dependencies..."
sudo apt-get install -y jq wget

yt-dlp -i \
  --extract-audio \
  --audio-format mp3 \
  --audio-quality 0 \
  --retries 100 \
  --min-sleep-interval 3 \
  --max-sleep-interval 10 \
  --cookies-from-browser firefox \
  --js-runtimes node \
  --output "%(uploader).50B - %(upload_date>%Y-%m-%d)s - %(title).100B [%(id)s].%(ext)s" \
  "$@"
