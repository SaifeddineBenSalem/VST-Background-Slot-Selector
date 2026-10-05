# 🚗 VST Background Slot Selector

<p align="center">
  <strong>A lightweight MoonLoader Lua script for SA-MP vehicle storage management</strong><br>
  <em>Search your Vehicle Storage directly while typing <code>/vst</code>, then select vehicles by slot without opening the dialog manually.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SA--MP-MoonLoader-blue?style=for-the-badge" alt="SA-MP MoonLoader">
  <img src="https://img.shields.io/badge/Language-Lua-2C2D72?style=for-the-badge&logo=lua" alt="Lua">
  <img src="https://img.shields.io/badge/FFI-Enabled-orange?style=for-the-badge" alt="LuaJIT FFI">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status">
</p>

---

## 📖 Overview

**VST Background Slot Selector** is a MoonLoader script designed for **SA-MP (San Andreas Multiplayer)** servers that use a **Vehicle Storage / VST** dialog.

Instead of repeatedly opening the server's Vehicle Storage dialog just to find a vehicle, the script provides a lightweight **background suggestion list** while the player types:

```text
/vst
```

The script automatically requests the server's VST list in the background, reads the dialog contents, caches the vehicle entries, and displays matching vehicles near the real SA-MP chat input.

It also adds a convenient numeric command:

```text
/vst 1
/vst 2
/vst 6
```

The selected slot is sent directly to the server dialog without requiring the player to manually open and click through the VST menu.

> **Important:** This script works by interacting with the SA-MP dialog/event system. The exact VST dialog title and vehicle-list format therefore depend on the server implementation.

---

## ✨ Features

### 🔎 Live Vehicle Search

Type:

```text
/vst
```

and the script displays the cached vehicle list.

You can also filter the list by typing text after `/vst`:

```text
/vst infernus
/vst sultan
/vst buffalo
```

The search is **case-insensitive** and performs a simple substring match.

---

### 🚘 Vehicle Slot Selection

Select a vehicle directly by its displayed slot number:

```text
/vst 1
```

```text
/vst 2
```

```text
/vst 10
```

The script:

1. Intercepts `/vst [number]`.
2. Prevents the original command from being sent unchanged.
3. Requests the real VST dialog from the server.
4. Validates the requested slot.
5. Converts the 1-based slot to the SA-MP dialog's 0-based row index.
6. Sends the dialog response automatically.
7. Closes the dialog.
8. Clears the cached list so the next search can retrieve fresh server data.

---

### ⚡ Background VST Loading

When `/vst` is typed for the first time and no vehicle list is cached, the script automatically sends:

```text
/vst
```

to retrieve the server's current Vehicle Storage list.

The resulting dialog is suppressed from the player's screen.

This means the player can continue using the chat-based selector without manually interacting with the VST dialog.

---

### 🎯 Real Chat Input Position

The suggestion list is not positioned using a fixed screen coordinate.

The script uses the SA-MP input structures through **LuaJIT FFI** to retrieve the actual position of the chat input.

This allows the suggestion list to be positioned relative to the real SA-MP chat input.

Relevant structures include:

- `stInputBox`
- `stInputInfo`

---

### 🎨 Vehicle Status Colors

Vehicle entries are displayed according to their detected status:

| Status | Display |
|---|---|
| `Stored` | ⚪ White |
| `Spawned` | 🟢 Green |

The script checks whether the cleaned vehicle entry contains the word:

```text
spawned
```

If found, the entry is rendered in green.

Otherwise, it uses white.

---

### 📋 Maximum Visible Results

The selector displays up to:

```lua
MAX_VISIBLE = 12
```

vehicles at once.

This prevents the suggestion list from becoming excessively large.

---

### 🧹 SA-MP Color Code Removal

The script removes SA-MP hexadecimal color codes before displaying vehicle names.

For example:

```text
{FF0000}Infernus
```

becomes:

```text
Infernus
```

This keeps the selector clean and readable.

---

## 🧩 How It Works

The script is built around three main mechanisms:

```text
                 ┌──────────────────┐
                 │ Player types     │
                 │ /vst              │
                 └────────┬─────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │ Check cached VST list │
              └───────────┬───────────┘
                          │
                    List missing?
                     /          \
                   YES           NO
                    │             │
                    ▼             │
             ┌─────────────┐      │
             │ Send /vst   │      │
             │ in background│     │
             └──────┬──────┘      │
                    │              │
                    ▼              ▼
             ┌────────────────────────┐
             │ Capture VST dialog     │
             │ and parse vehicle list │
             └────────────┬───────────┘
                          │
                          ▼
                ┌───────────────────┐
                │ Display matches   │
                │ near chat input   │
                └───────────────────┘
```

---

# 🏗️ Architecture

## 1. Dependencies

The script imports:

```lua
require "lib.moonloader"
local sampev = require "lib.samp.events"
local ffi = require "ffi"
```

### `lib.moonloader`

Provides MoonLoader functionality required by the script.

### `lib.samp.events`

Provides SA-MP event hooks such as:

```lua
sampev.onSendCommand()
sampev.onShowDialog()
```

### `ffi`

LuaJIT FFI is used to access the SA-MP input structures and determine the real chat input position.

---

## 2. SA-MP Input Structures

The script defines two C-compatible structures:

```c
typedef struct stInputBox
{
    void* pUnknown;

    uint8_t bIsChatboxOpen;
    uint8_t bIsMouseInChatbox;
    uint8_t bMouseClickRelated;
    uint8_t unk;

    uint32_t dwPosChatInput[2];

    uint8_t unk2[263];

    int iCursorPosition;

    uint8_t unk3;

    int iMarkedTextStartPos;

    uint8_t unk4[20];

    int iMouseLeftButton;

} stInputBox;
```

and:

```c
typedef struct stInputInfo
{
    void* pD3DDevice;
    void* pDXUTDialog;
    stInputBox* pDXUTEditBox;

} stInputInfo;
```

These structures allow the script to access:

```text
dwPosChatInput[0] → X position
dwPosChatInput[1] → Y position
```

---

# 🔄 Main Workflow

## Step 1 — Wait for SA-MP

The script waits until SA-MP is available:

```lua
repeat
    wait(0)
until isSampAvailable()
```

Once available, it prints:

```text
[VST] Background selector loaded. Created by Saifeddine Ben Salem.
```

---

## Step 2 — Detect Chat Input

Every frame, the script checks:

```lua
sampIsChatInputActive()
```

If the chat input is active, it retrieves the current text:

```lua
sampGetChatInputText()
```

---

## Step 3 — Detect `/vst`

The script checks whether the input begins with:

```text
/vst
```

using a case-insensitive pattern.

Examples recognized:

```text
/vst
/VST
/vst infernus
/vst sultan
/vst 5
```

---

## Step 4 — Automatically Load the Vehicle List

If `/vst` is detected and there is no cached vehicle list:

```lua
if #carSlots == 0 and not requestingVST then
```

the script sends:

```lua
sampSendChat("/vst")
```

The resulting VST dialog is intercepted and hidden.

---

## Step 5 — Parse the Dialog

When the server displays the VST dialog, the script checks its title.

It only processes dialogs containing:

```text
vehicle storage
```

This prevents unrelated SA-MP dialogs from being affected.

The dialog text is split into individual lines.

Empty lines are ignored.

---

## Step 6 — Cache the Vehicles

The parsed lines are stored inside:

```lua
carSlots
```

The structure is essentially:

```text
carSlots
 ├── 1 → Vehicle 1
 ├── 2 → Vehicle 2
 ├── 3 → Vehicle 3
 ├── ...
 └── N → Vehicle N
```

---

# 🔍 Search System

The search text is extracted from everything after `/vst`.

For example:

```text
/vst infer
```

produces:

```text
infer
```

The search is normalized to lowercase.

The script then compares it against each vehicle entry:

```lua
clean:lower():find(search, 1, true)
```

The `true` argument makes the search a **plain substring search** rather than a Lua pattern search.

### Example

Cached vehicles:

```text
1  Infernus - Stored
2  Sultan - Spawned
3  Buffalo - Stored
4  Turismo - Spawned
```

Typing:

```text
/vst tur
```

produces:

```text
4  Turismo - Spawned
```

---

# 🎮 Commands

## `/vst`

Opens the original server VST interface normally when used manually.

```text
/vst
```

The script also uses this command internally to refresh its vehicle cache.

---

## `/vst [slot]`

Selects a vehicle by its VST slot.

Examples:

```text
/vst 1
/vst 2
/vst 5
/vst 10
```

The command is intercepted by:

```lua
sampev.onSendCommand(command)
```

The original command is cancelled:

```lua
return false
```

and the script handles the selection itself.

---

## `/vst [search]`

Searches cached vehicles.

Examples:

```text
/vst infernus
/vst sultan
/vst spawned
```

The search is performed against the cleaned vehicle text.

---

# 🖥️ Display Configuration

The selector can be positioned and sized using the following variables:

```lua
local LINE_HEIGHT = 21
local MAX_VISIBLE = 12

local LIST_X_OFFSET = 0
local LIST_Y_OFFSET = 30

local CHAT_INPUT_HEIGHT = 28
```

### `LINE_HEIGHT`

Vertical spacing between vehicle entries.

Default:

```text
21 pixels
```

### `MAX_VISIBLE`

Maximum number of displayed results.

Default:

```text
12
```

### `LIST_X_OFFSET`

Horizontal adjustment relative to the SA-MP chat input.

Default:

```text
0
```

### `LIST_Y_OFFSET`

Vertical adjustment relative to the chat input.

Default:

```text
30
```

### `CHAT_INPUT_HEIGHT`

Approximate height of the SA-MP chat input.

Default:

```text
28
```

---

# 🧠 State Management

The script uses four main state variables:

```lua
local carSlots = {}
local pendingSlot = nil
local requestingVST = false
local suppressNextVSTDialog = false
```

## `carSlots`

Stores the currently cached vehicle list.

---

## `pendingSlot`

Stores the vehicle slot requested by:

```text
/vst [number]
```

Example:

```text
/vst 6
```

results in:

```lua
pendingSlot = 6
```

---

## `requestingVST`

Prevents multiple automatic `/vst` requests from being sent simultaneously.

---

## `suppressNextVSTDialog`

Indicates that the next VST dialog was opened automatically by the script and should therefore remain hidden.

---

# 🔢 Dialog Slot Conversion

SA-MP dialog rows are zero-based.

The user-facing VST slot is one-based.

Therefore:

```text
VST Slot 1 → Dialog Row 0
VST Slot 2 → Dialog Row 1
VST Slot 3 → Dialog Row 2
```

The script performs this conversion:

```lua
local row = pendingSlot - 1
```

It then responds to the dialog with:

```lua
sampSendDialogResponse(
    id,
    1,
    row,
    ""
)
```

This selects the requested vehicle.

---

# 🛡️ Safety / Validation

The script performs several checks before interacting with the VST dialog.

### Invalid slot

A slot below `1` is rejected:

```lua
if slot < 1 then
    return false
end
```

### Empty vehicle list

If the server returns no vehicles, the pending selection is cleared.

### Slot outside the available range

For example, if there are only 5 vehicles:

```text
/vst 10
```

is ignored because:

```text
10 > 5
```

### Non-VST dialogs

Only dialogs whose title contains:

```text
vehicle storage
```

are processed.

Other SA-MP dialogs remain untouched.

---

# 🔄 Cache Refresh Strategy

After selecting a vehicle through:

```text
/vst [slot]
```

the script clears:

```lua
carSlots = {}
```

The reason is intentional: the script does **not** assume that the requested vehicle successfully spawned.

Instead, the next `/vst` search retrieves the current state from the server.

This avoids displaying potentially outdated `Stored` / `Spawned` information.

---

# 📁 Installation

## Requirements

You need:

- **GTA: San Andreas**
- **SA-MP**
- **MoonLoader**
- MoonLoader's standard SA-MP/Lua environment
- `lib.samp.events`
- LuaJIT FFI support

---

## Installation Steps

### 1. Download the script

Place the Lua file into your MoonLoader scripts directory.

Typical location:

```text
GTA San Andreas/
└── moonloader/
    └── vst_background_slot_selector.lua
```

The filename can be changed as desired.

---

### 2. Start SA-MP

Launch your SA-MP client and connect to the server.

---

### 3. Verify Loading

After SA-MP becomes available, the script displays:

```text
[VST] Background selector loaded. Created by Saifeddine Ben Salem.
```

---

### 4. Use `/vst`

Type:

```text
/vst
```

The script will retrieve the Vehicle Storage list.

Then try:

```text
/vst
```

followed by a vehicle name to filter the cached list.

---

# 📌 Example Usage

Suppose the server returns:

```text
1  Infernus - Stored
2  Sultan - Spawned
3  Buffalo - Stored
4  Turismo - Stored
5  Elegy - Spawned
```

Typing:

```text
/vst
```

shows the available entries.

Typing:

```text
/vst sul
```

filters the list to:

```text
2  Sultan - Spawned
```

To select slot 2:

```text
/vst 2
```

The script automatically opens the server VST dialog in the background and selects row `1`.

---

# 🎨 UI Behavior

The selector is intentionally minimal.

It renders **text only**, without adding custom backgrounds or large interface elements.

Example:

```text
1  Infernus - Stored
2  Sultan - Spawned
3  Buffalo - Stored
4  Turismo - Spawned
```

Stored vehicles are white.

Spawned vehicles are green.

This keeps the selector visually close to the SA-MP chat experience.

---

# 🧰 Customization

## Change Font

The current font is:

```lua
renderCreateFont(
    "Arial",
    11,
    5
)
```

You can change:

```text
Arial
```

to another installed font.

You can also adjust the font size:

```lua
11
```

---

## Change Number of Results

Modify:

```lua
local MAX_VISIBLE = 12
```

For example:

```lua
local MAX_VISIBLE = 20
```

---

## Move the Selector Horizontally

Modify:

```lua
local LIST_X_OFFSET = 0
```

Example:

```lua
local LIST_X_OFFSET = 15
```

---

## Move the Selector Vertically

Modify:

```lua
local LIST_Y_OFFSET = 30
```

Example:

```lua
local LIST_Y_OFFSET = 45
```

---

## Change Row Spacing

Modify:

```lua
local LINE_HEIGHT = 21
```

Example:

```lua
local LINE_HEIGHT = 24
```

---

# 🧪 Compatibility Notes

This script relies on the structure and behavior of the server's Vehicle Storage system.

For the automatic selector to work correctly, the server should generally provide:

1. A `/vst` command.
2. A dialog representing Vehicle Storage.
3. A dialog title containing `Vehicle Storage`.
4. Vehicle entries separated by lines.
5. A dialog row corresponding to each vehicle.

The script is therefore **server-implementation dependent**.

If a server uses a different dialog title or a completely different VST architecture, the detection logic may need to be adjusted.

---

# ⚠️ Limitations

### Server-specific VST format

The script expects a dialog title containing:

```text
Vehicle Storage
```

If the server uses another title, this condition needs to be changed.

---

### Status detection

The status color is based on whether the vehicle entry contains:

```text
spawned
```

This means the script does not independently determine whether a vehicle is spawned.

It relies on the text supplied by the server.

---

### No server-side vehicle database

The script does not maintain its own persistent vehicle database.

It only caches the VST data received from the server.

---

### No guessing after selection

After `/vst [slot]`, the cache is cleared because the script intentionally does not assume that spawning succeeded.

The server remains the authoritative source of the vehicle state.

---

# 🔐 Data & Privacy

The script does not implement an external API, database, telemetry system, or remote data collection mechanism.

Its functionality is centered around:

- SA-MP chat input
- SA-MP dialogs
- Vehicle Storage data supplied by the connected server
- Local MoonLoader rendering

No external server is required by the script itself.

---

# 🧑‍💻 Code Structure

The script is organized into several logical sections:

```text
VST Background Slot Selector
│
├── Script metadata
│
├── Dependencies
│
├── SA-MP input structures
│
├── State variables
│
├── Font configuration
│
├── Display settings
│
├── Utility functions
│   ├── trim()
│   ├── stripColors()
│   └── getLines()
│
├── VST input detection
│   ├── isVSTInput()
│   └── getSearchText()
│
├── Vehicle filtering
│   └── getMatches()
│
├── Chat input positioning
│   └── getRealChatInputPosition()
│
├── Suggestion rendering
│   └── drawVehicleSuggestions()
│
├── Main loop
│
├── /vst [number] interception
│   └── sampev.onSendCommand()
│
└── VST dialog processing
    └── sampev.onShowDialog()
```

---

# 🐛 Troubleshooting

## The selector does not appear

Check that:

- MoonLoader is installed correctly.
- The script is inside the `moonloader` directory.
- SA-MP is running.
- The console/chat displays the loading message.
- The server actually provides a VST dialog.
- The VST dialog title contains `Vehicle Storage`.

---

## `/vst` works but the selector stays empty

The script only caches the VST list after receiving a matching Vehicle Storage dialog.

Check whether the server uses a different dialog title.

The relevant condition is:

```lua
titleLower:find("vehicle storage", 1, true)
```

---

## `/vst [number]` does nothing

Verify that:

- The slot number is greater than `0`.
- The requested slot exists.
- The server's VST dialog is being detected.
- The VST dialog uses normal selectable rows.

---

## Vehicle status is not colored correctly

The current detection looks for:

```text
spawned
```

inside the vehicle entry.

If the server uses another word such as:

```text
Spawn
Active
Out
In Use
```

the status detection logic would need to be customized.

---

## The selector position is incorrect

Adjust:

```lua
LIST_X_OFFSET
LIST_Y_OFFSET
CHAT_INPUT_HEIGHT
```

These values control the selector's position relative to the SA-MP chat input.

---

# 📜 License

No explicit license is defined in the source code.

If you publish this project publicly, consider adding a license such as:

- MIT
- GPL-3.0
- Apache-2.0

or a custom license specifying whether redistribution and modification are permitted.

---

# 👨‍💻 Author

**Saifeddine Ben Salem**

> Computer Scientist · Big Data & Data Analytics · Full Stack Developer

Created as a MoonLoader utility for improving Vehicle Storage interaction in SA-MP.

---

# ⭐ Support the Project

If this script is useful to you:

- ⭐ Star the repository
- 🐛 Report bugs
- 💡 Suggest improvements
- 🔧 Submit compatible improvements
- 📢 Share it with other SA-MP/MoonLoader developers

---

<p align="center">
  <strong>Built with Lua + MoonLoader + SA-MP Events + LuaJIT FFI</strong><br>
  <sub>VST Background Slot Selector · Saifeddine Ben Salem</sub>
</p>
