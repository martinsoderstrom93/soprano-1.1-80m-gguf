#!/usr/bin/env bash
# Reproduce the Soprano 1.1 80M GGUF pair and the release archive.
#
#   ./convert.sh WORK_DIR
#
# Needs git, git-lfs (or huggingface-cli), Python 3 with torch and transformers, and zip
# support in Python. Every input and output is checked against SHA256SUMS-style pins.
set -euo pipefail

WORK=${1:?work directory}
LLAMA_COMMIT=19cce6919992fdffd92e0ac152caaf1e2b8f254e
SOPRANO_REVISION=27b5a5f5f541a1db3a51d6fd1b0fc7147b92cd01
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$WORK"
cd "$WORK"

[ -d llama.cpp ] || git clone https://github.com/ggml-org/llama.cpp.git
git -C llama.cpp checkout --quiet "$LLAMA_COMMIT"

[ -d Soprano-1.1-80M ] || git clone https://huggingface.co/ekwek/Soprano-1.1-80M
git -C Soprano-1.1-80M checkout --quiet "$SOPRANO_REVISION"
sha256sum -c - <<'EOF'
10e8c4223e14115688a1c8a1c5464ebb78826f17fb98ad459da9bce5471866ed  Soprano-1.1-80M/model.safetensors
11245487e4588b0f4128d6b4c82035212bad42ffb26f36e059e9c7f861c1f8c4  Soprano-1.1-80M/decoder.pth
EOF

mkdir -p soprano-1.1-80m
python llama.cpp/convert_hf_to_gguf.py Soprano-1.1-80M --outtype q8_0 --outfile soprano-1.1-80m/soprano-1.1-q8_0.gguf
python llama.cpp/convert_hf_to_gguf.py Soprano-1.1-80M --mmproj --outtype f16 --outfile soprano-1.1-80m/mmproj-soprano-1.1-f16.gguf
cp "$HERE/LICENSE" soprano-1.1-80m/LICENSE

# Stored entries, fixed timestamps and permissions: the archive hash is reproducible.
python - <<'EOF'
import zipfile
with zipfile.ZipFile("soprano-1.1-80m-q8_0.zip", "w", zipfile.ZIP_STORED) as z:
    for name in ["soprano-1.1-q8_0.gguf", "mmproj-soprano-1.1-f16.gguf", "LICENSE"]:
        info = zipfile.ZipInfo(f"soprano-1.1-80m/{name}", date_time=(1980, 1, 1, 0, 0, 0))
        info.external_attr = 0o644 << 16
        with open(f"soprano-1.1-80m/{name}", "rb") as f:
            z.writestr(info, f.read())
EOF
sha256sum -c "$HERE/SHA256SUMS"
