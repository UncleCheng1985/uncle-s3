# License scope and provenance

The adjacent MIT [LICENSE.txt](LICENSE.txt) covers only this developer kit's new
documentation, interface declarations, tools, tests, template and original
examples/resources. Retain notices on redistribution. It does not grant a license
to the whole UNCLE/BeatVocab firmware, PCB, hardware, branding, product photograph,
compiled fonts, dependency binaries, downloaded songs or unrelated artwork.

| Included item | Origin / permission |
| --- | --- |
| AGENTS, API reference/JSON/declarations, guides, tools, tests | Project-authored for this public kit; MIT |
| Stick Lab main.lua | Existing original project-authored international example with adjacent MIT; copied byte-for-byte from the audited example source |
| Starter, Coin Dash, Pocket Counter | New original Lua examples for this kit; MIT; no third-party engine/game code |
| Coin Dash sprite/tone | Original procedural16×16 geometric coin and80ms waveform; MIT; source generator and raw/WAV included |
| runtime-audit.json | Function-name/format audit and source fingerprints only; does not distribute firmware code |

No fonts, third-party media, deity/city game art, commercial console assets, word
collections, owner music, customer recording, credentials, Flash dump, NVS or
firmware image is included. Examples call existing device fonts; these must be
provided by the compatible firmware under its own separate release terms.
Optional Python/Lua interpreters are installed separately under their own terms.
No paid model API is used by the tools and no AI account/subscription is provided.

Public API names/semantics were checked against the actual Lua bindings, loader,
manifest parser, assets/mixer/storage implementation and build config. The audit
applies to the fingerprinted preview build only; API1 isn't blanket future/older
firmware compatibility. Release validation limits are stated in VALIDATION.md.
