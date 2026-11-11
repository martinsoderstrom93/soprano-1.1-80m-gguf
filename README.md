# Soprano 1.1 80M — GGUF for llama.cpp

GGUF conversions of [Soprano 1.1 80M](https://huggingface.co/ekwek/Soprano-1.1-80M), a small
English text-to-speech model, for llama.cpp's native Soprano support. A complete voice is
**two files**: the language-model backbone and the Vocos audio decoder. Community GGUFs found
elsewhere contain only the backbone.

I made these for my own use. They work with any llama.cpp build at the revision below or
later that includes Soprano support.

This is an unofficial conversion. It is not made or endorsed by the Soprano author.

## Files

The release asset `soprano-1.1-80m-q8_0.zip` (stored, not compressed) contains:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `soprano-1.1-80m/soprano-1.1-q8_0.gguf` | 84,921,280 | `31d11806b1fd7668cb8bb570b9abd07c6d351e15539c271bc3c87aba8ca857f3` |
| `soprano-1.1-80m/mmproj-soprano-1.1-f16.gguf` | 60,821,312 | `c328e0548d3249b56055d019dd06cf95815c601fb48b43a14d6a6da5038558c5` |
| `soprano-1.1-80m/LICENSE` | 11,357 | `c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4` |

Archive: 145,754,405 bytes, SHA-256 `fac2056db70d10e3f9dcdc2a08865dcd262a9d98d01a1fd33f3c52fed945ea9f`.
`SHA256SUMS` lists all four hashes.

## Use with llama.cpp

```sh
unzip soprano-1.1-80m-q8_0.zip
llama-tts -m soprano-1.1-80m/soprano-1.1-q8_0.gguf \
  -mm soprano-1.1-80m/mmproj-soprano-1.1-f16.gguf \
  -c 1024 --temp 0 --repeat-penalty 1.2 -p "hello from soprano." -o out.wav
```

Output is 32 kHz mono. Soprano expects text that has already been normalized the way the
official Python package does (`soprano/utils/text_normalizer.py`): numbers, dates and
abbreviations spelled out, lowercase. Upstream `llama-tts` leaves the decoder on 4 threads
whatever `-t` says; set `mtmd_context_params.n_threads` yourself if you embed it.

## Measured on a phone

On a Samsung Galaxy A54 (Android, 4 CPU threads, this Q8_0 pair), a 28-second English
passage was generated about five times faster than real time, with roughly 1 second to the
first sentence and about 293 MB peak memory. These are one device's results, not a
benchmark.

## Provenance

| Input | Revision |
| --- | --- |
| Checkpoint `ekwek/Soprano-1.1-80M` | `27b5a5f5f541a1db3a51d6fd1b0fc7147b92cd01` |
| Converter: llama.cpp `convert_hf_to_gguf.py` | `19cce6919992fdffd92e0ac152caaf1e2b8f254e` |

Checkpoint files used (SHA-256 matches the Hugging Face LFS hashes):

```text
10e8c4223e14115688a1c8a1c5464ebb78826f17fb98ad459da9bce5471866ed  model.safetensors
11245487e4588b0f4128d6b4c82035212bad42ffb26f36e059e9c7f861c1f8c4  decoder.pth
```

Converted with Python 3.14, torch 2.11.0+cpu and transformers 5.22.2 (the decoder is loaded
with `weights_only=True`). `convert.sh` reproduces the conversion and the archive; other
package versions may produce numerically equal but not byte-identical files. Changes from the original: format
conversion to GGUF, the backbone quantized to Q8_0 and the decoder stored as F16. No weights
were retrained or otherwise modified.

## Licence

Soprano's code and weights are released under the Apache License 2.0, and so are these
converted files. `LICENSE` is the licence text from the Soprano source repository. Soprano is
the work of its author; see the [model card](https://huggingface.co/ekwek/Soprano-1.1-80M).
