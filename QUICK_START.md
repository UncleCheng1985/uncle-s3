# Quick start

[Back to UNCLE S3](README.md)

Applies to ESP32-S3 Joystick v0.2 running the international firmware. An app appearing on the home screen does not imply all card formats, accessories and fault conditions have been tested.

## 1. Connect and start

1. Place the board on a clean nonconductive surface. Avoid loose metal objects and exposed battery contacts.
2. Check that the matching display, joystick and speaker are fitted as described for your shipped kit. Do not connect or disconnect their small FPC cables while powered.
3. If your card is supplied prepared, keep its files and make a backup using a card reader before editing. The public [Lua developer kit](developer-kit/README.md) includes standalone examples and packaging; use its [first-run guide](developer-kit/docs/WINDOWS.md). It is not the full shipped card image. Do not format the supplied card as a first troubleshooting step.
4. Connect a suitable USB-C cable to a regulated 5 V USB supply. A battery is not required for this setup.
5. Find the firmware version under Settings → About when reporting an issue.

The verified card-capacity/filesystem recommendation and final shipped firmware version will accompany the release. Do not assume that every microSD format or capacity works.

## 2. Basic controls

| Control | Action |
| --- | --- |
| Stick left/right | Select a home-screen app; continue moving to reach Reader and Settings. |
| Stick press (L3) | Confirm a selection. |
| Stick up/down | Navigate applicable lists and game-library rows. |
| POWER | Open the system menu. Choose Continue or Exit to home as appropriate. |
| VOL+ / VOL− | Adjust system volume. |

Release the stick after entering or resuming an app to avoid unintended input. There is no touchscreen, A/B button or shoulder button. Use the POWER menu for an exit if the app's Back control is not selected.

POWER also provides screen-off/software-shutdown functions. Software shutdown is not a physical battery disconnect. Do not use BOOT or RESET as ordinary application controls.

## 3. Files on the card

```text
/Games/<game-id>/game.json
/Games/<game-id>/main.lua
/Games/<game-id>/<required assets>
/Music/<your MP3 or supported WAV files>
/Books/<your UTF-8 TXT files>
/Recordings/<WAV files saved by Recorder>
```

Some game files are optional, but required asset packs must stay with the matching script. Preserve saves and back up the card before changing content. Folder names and game IDs must match. Stop recording/playback and power down/disconnect USB before removing the card; validated hot-swap behavior is not promised.

Only copy media you have permission to use. Songs seen in a demo are not necessarily supplied with the kit.

## 4. Use the apps

### Games

Move within the four-column cover grid using the stick; press to launch. Select Back at the grid boundary to leave, or use POWER → Exit to home. Game controls are shown on screen and vary by game. Portrait games require holding the device in the corresponding orientation.

### Music

Put supported files in `/Music`. Select a track and press to start. Select the previous, pause/resume, next or playback-mode icon and press to activate it. Use VOL to adjust volume.

Music can continue at home or in Reader/Focus. Starting a game or recording takes over audio. Reboot does not automatically resume a track.

### Recorder

Choose Record, then Stop to save. Files are named `/Recordings/REC00001.wav` and onward using unused numbers. Recent recordings can be selected for playback.

**Opening the POWER menu stops and saves an active recording.** Each file is limited to about 11 minutes 39 seconds. Do not disconnect power or remove the card while recording.

### Focus

Choose a plan or customize focus duration, break duration and rounds. Press to edit an available value, use left/right to change it, then press to confirm. Start, pause/resume and end controls are available. Start breaks manually after a focus session.

The timer can continue at home or with the screen off while the device remains powered. Software shutdown saves a paused checkpoint; it does not keep counting while powered off. Completion sound follows system volume and can be skipped if audio remains occupied.

### Reader

Put UTF-8 English `.txt` files in `/Books` and open one with the stick press. In reading view:

- Right, down or press: next page.
- Up: previous page.
- Left: reading controls for Back, paging, spacing and theme.
- POWER: system menu and exit.

Reading position is saved after a delay and on normal exit. PDF and EPUB are not supported.

### Settings

Adjust brightness, view volume and saved joystick calibration, access existing wireless settings and read firmware information. Joystick calibration editing currently uses a USB developer workflow; there is no on-device calibration wizard.

## 5. If something does not work

- No games/music/books: check the card is detected, folder names and file formats are correct, and the script's required assets were copied together.
- Script error: note the exact message, return to the system and test an unmodified compatible example.
- No sound: check volume, selected output and whether another app is using audio.
- Poor joystick navigation: release and recenter the stick; report the saved calibration and firmware version to the seller rather than copying someone else's calibration.
- Unresponsive application: try the POWER menu. The hardware long-press reset exists, but resetting during file writes may lose data; allow a recording to stop/save whenever possible.

For firmware recovery, obtain the board-specific verified instructions from the seller. This repository does not yet publish a recovery binary. Never erase NVS or the whole Flash as a routine first step.
