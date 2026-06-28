# Plasphere

A multichannel SuperCollider sound installation.

## Project structure

```
Plasphere/
├── Code/                  # All source (this is the "project" dir main.scd runs from)
│   ├── main.scd           # Entry point: boots the server and loads everything
│   ├── script.scd         # Performance / playback script
│   ├── tests.scd          # Scratch / test code
│   ├── setup/
│   │   ├── setup.scd       # Loads audio + spectral buffers
│   │   ├── routines.scd    # Layer routines (water / land / humans / machines / grains)
│   │   └── routines_old.scd
│   └── synthdefs/
│       ├── synths.scd      # SynthDefs (auto-loaded by main.scd)
│       └── fx.scd          # FX SynthDefs (auto-loaded by main.scd)
└── Buffers/               # Audio assets — downloaded separately (NOT in git)
    ├── Audio/
    │   └── Sources/
    │       ├── water/      # *.wav
    │       ├── land/       # *.wav
    │       ├── humans/     # *.wav
    │       └── machines/   # *.wav
    └── Data/
        └── FFT/            # *_spec.wav  (spectral / PV buffers)
```

`Code/main.scd` resolves its paths relative to itself: it treats its own folder
(`Code/`) as the project root and looks **one level up** for the sibling
`Buffers/` directory. So `Code/` and `Buffers/` must sit next to each other
inside `Plasphere/`.

## Buffers

The `Buffers/` directory is not committed to git. Download it and place it at the
repo root (so you end up with `Plasphere/Buffers/`):

https://drive.google.com/drive/folders/1L3RY5hAGVyIhny_cSwc5zCVORpQW-giC?usp=sharing

## Running

Open `Code/main.scd` in the SuperCollider IDE and evaluate it. It boots the
server, loads `setup/setup.scd` and `setup/routines.scd`, then loads every
SynthDef in `synthdefs/`.
