# Compatibility contract

- Kit version: **0.1.0**, audited 2026-10-18.
- Board: **ESP32-S3 Joystick v0.2 international edition**, not ESP32-P4/C3 or old S3 boards.
- Runtime: **Lua5.4.9, API1, LUA_32BITS=1**: signed 32-bit integers and single-precision
  floats. A desktop Lua5.4 interpreter commonly uses wider numbers; a host pass is
  not numerical/heap/timing equivalence with the device.
- Audited installed build: **0.2.0-intl-preview.9**, jazz-maintenance application patch.
  Exact application SHA256:
  `feb61434fbf3e64938cfcbf6b41dd8c91216318526f4e5c44990bf2c2b346d92`.
- Settings → About shows the preview version, not a cryptographic binary identity.
  A matching `api:1` alone does not guarantee every binding in older builds.
  This kit's compatibility promise is the audited build only; ask the seller if unsure.
- Source binding/loader/format fingerprints are in [runtime-audit.json](api/runtime-audit.json).
  They record the audit, not firmware source distribution or independent build reproducibility.
- Screen: 960×376 landscape or 376×960 portrait as selected by the manifest.
- Input: one two-axis stick plus L3 confirm; POWER and VOL± are reserved system keys.
- Only one foreground Lua project; there are no background Lua services.

This package is **content development only**. No firmware flash is needed to change
compatible scripts/resources. There is no downloadable firmware in this kit because
whole-firmware license/notices and customer recovery are separate release gates.
Do not erase Flash/NVS or use random ESP32 images to make an example work. Obtain a
verified v0.2 international build and board-specific recovery instructions from the
seller if the device is incompatible. Retain the shipped calibration and all saves.
