# Known limitations and release status

[Back to UNCLE S3](README.md)

Documentation prepared 2026-10-18 for the ESP32-S3 Joystick v0.2 international edition. The latest internal development record identifies firmware `0.2.0-intl-preview.9` with a subsequent maintenance patch. This is not a claim that the final customer firmware or public download package has been released.

## Power and battery

- Use USB-C 5 V for initial operation. No USB PD high-voltage input is supported.
- Routine automatic battery charging is not enabled in the documented normal firmware. Controlled charging tests did not establish full-charge termination; charge current, runtime, standby consumption and temperature performance are not fully characterized.
- A battery is not included in the base kit. Battery use requires a compatible protected single-cell pack and verified wiring. The v0.2 battery connector J6 is 1.20 mm pitch: pin 1 is GND/PACK− and pin 2 is BAT_B+/PACK+. A similar-looking connector or wire color does not establish compatibility.
- Software shutdown does not physically disconnect the battery. There is no battery-temperature-monitoring claim.

## Apps and storage

- Games use a bounded device API, not arbitrary Lua modules or commercial console emulation. The current library has a 16-game limit. No fixed frame rate is promised.
- MP3 is the primary music format. Supported uncompressed PCM16 WAV files are mono/stereo at 8–48 kHz. Video playback is not included.
- Recorder currently limits each file to 64 MiB of PCM, approximately 11 minutes 39 seconds. Long recordings and microphone quality still need broader validation; power-loss WAV recovery is not provided.
- Reader supports UTF-8 English TXT, including a UTF-8 BOM. UTF-16, legacy encodings, embedded NUL, PDF and EPUB are not supported. The browser has a 64-entry limit; deep backward paging can be slow. Same-size file edits may not reset an old bookmark.
- Focus shows this-boot/set statistics, not verified date-based daily totals. It does not provide powered-off timing or scheduled wake-up. A checkpoint interval can be lost after sudden power removal. The completion sound can be skipped if audio remains busy.
- Full fault testing for empty/full/failing cards, physical hot removal and all card capacities is incomplete. Back up your files and stop writing before removing the card.

## Hardware and development

- There is no touchscreen, A/B/L/R, IMU or vibration motor in this S3 version.
- GPIOs are heavily allocated to onboard functions; general-purpose expansion headers are not promised.
- Wi-Fi/BLE hardware does not mean Bluetooth headphone audio or every wireless workload has been validated.
- Basic wired headphone operation has been checked with a specific headset. Universal headphone/headset and inline-control compatibility is not guaranteed.
- Joystick calibration editing uses the current USB developer process. Do not copy another board's saved calibration or NVS.
- USB file transfer is not advertised as a standard drag-and-drop mass-storage drive. Use a card reader for card-content installation.

## Public downloads and rights

This repository now includes the [Lua content developer kit](developer-kit/README.md),
original licensed examples/tools and a versioned source ZIP. Its [validation record](developer-kit/VALIDATION.md)
separates host checks and prepared deployment archives from pending device runs.
It does not provide a public firmware binary or full customer-card image; firmware
notices/customer recovery remain separate. Customer-device backups, Wi-Fi settings,
personal recordings and owner-device music are excluded.

The developer firmware is not a certification of the full product. This documentation makes no CE/FCC or other complete-product certification claim. Public source-code scope, hardware design release and artwork permissions must be stated explicitly before those files are published.
