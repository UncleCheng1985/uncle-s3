# Stick Lab

Existing original minimal example from the audited international firmware project.
Four directions move; L3 resets and increments the per-project reset counter.
POWER pauses/exits; VOL controls system volume. SPEED/COLOR are editable.
All necessary code is in main.lua; no external media. The original version was
previously run on v0.2; this public copy has host checks, not a new device test.
Use tools/uncle.py new --template examples/stick-lab projects/my-lab to preserve
the official example and get independent saves. MIT applies to this example only.
