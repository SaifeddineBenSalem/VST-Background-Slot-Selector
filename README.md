# 🚗 VST Background Slot Selector

<p align="center">

**A lightweight MoonLoader script that turns the SA-MP Vehicle Storage (`/vst`) system into a fast background vehicle selector.**

<br>

![SA-MP](https://img.shields.io/badge/SA--MP-Supported-blue?style=for-the-badge)
![MoonLoader](https://img.shields.io/badge/MoonLoader-Supported-green?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey?style=for-the-badge)

</p>

---

## 📌 Overview

**VST Background Slot Selector** is a Lua/MoonLoader script for **GTA: San Andreas Multiplayer (SA-MP)**.

It enhances servers that use a **Vehicle Storage / VST (`/vst`) dialog** by displaying the available vehicles directly underneath the SA-MP chat input while you type `/vst`.

Instead of repeatedly opening the Vehicle Storage dialog just to remember which vehicle is stored in which slot, the script displays the available vehicles directly below the chat input.

### Example

When you press `T` and type:

```text
/vst
```

the script can display:

```text
1  Vehicle: BF-400 | Status: Stored | Location: Glen Park
2  Vehicle: Broadway | Status: Stored | Location: Pershing Square
3  Vehicle: BMX | Status: Stored | Location: Glen Park
4  Vehicle: Bullet | Status: Stored | Location: Pershing Square
5  Vehicle: Benson | Status: Stored | Location: Ocean Docks
6  Vehicle: FCR-900 | Status: Stored | Location: Willowfield
```

The list appears **without a background**, directly underneath the actual SA-MP chat input.

---

# ✨ Features

## 🚗 Background Vehicle List

Press `T` and type:

```text
/vst
```

The available vehicles are displayed underneath the chat input.

No permanent dialog needs to remain open.

---

## 🔢 Fast Vehicle Slot Selection

You can directly select a vehicle using:

```text
/vst 1
```

or:

```text
/vst 2
```

or:

```text
/vst 3
```

and so on.

The script automatically:

1. Sends `/vst` to retrieve the server's current Vehicle Storage dialog.
2. Reads the vehicle slots.
3. Finds the requested slot.
4. Selects the corresponding vehicle.
5. Closes the dialog automatically.

The process happens in the background.

---

# 💬 Normal `/vst` Behavior Is Preserved

The script does **not permanently replace the server's `/vst` command**.

When you manually type:

```text
/vst
```

and press Enter, the server's original Vehicle Storage dialog can still appear normally.

The script is designed to add functionality without removing the normal VST system.

---

# 🔎 Vehicle Search

While typing `/vst`, the displayed list can be filtered.

For example:

```text
/vst bullet
```

can display:

```text
4  Vehicle: Bullet | Status: Stored | Location: Pershing Square
```

This is useful when a player has many vehicles stored.

---

# 🎨 Clean UI

The selector intentionally uses a minimal interface.

### No:

- ❌ Large custom window
- ❌ Dark rectangle
- ❌ Additional buttons
- ❌ Additional menus
- ❌ Constant SA-MP chat spam

### Instead:

- ✅ White text
- ✅ Larger Arial font
- ✅ Transparent background
- ✅ Positioned underneath the actual SA-MP chat input
- ✅ Lightweight rendering
- ✅ Minimal resource usage

---

# 🖥️ Requirements

You need:

- GTA San Andreas PC
- SA-MP
- MoonLoader
- Lua support
- A server using a compatible Vehicle Storage `/vst` dialog

The script is designed for the classic **Windows PC SA-MP environment**.

---

# 📥 Installing MoonLoader

If MoonLoader is already installed, skip to [Installing the Script](#-installing-the-script).

## 1. Install GTA San Andreas

You need a working PC installation of:

```text
Grand Theft Auto: San Andreas
```

The classic PC version is recommended for SA-MP and MoonLoader.

---

## 2. Install SA-MP

Install the SA-MP client into your GTA San Andreas directory.

Your GTA directory may look similar to:

```text
C:\Program Files (x86)\Rockstar Games\GTA San Andreas\
```

or:

```text
C:\Games\GTA San Andreas\
```

Your actual installation directory may be different.

---

## 3. Install MoonLoader

Install a MoonLoader version compatible with your SA-MP installation.

After installation, your GTA San Andreas directory should contain a folder similar to:

```text
moonloader\
```

For example:

```text
GTA San Andreas/
│
├── gta_sa.exe
├── samp.exe
├── moonloader/
│   ├── lib/
│   └── ...
│
└── ...
```

MoonLoader is required because this project is written as a Lua MoonLoader script.

---

# 📦 Installing the Script

Download or copy:

```text
vst_background_selector.lua
```

and place it inside:

```text
GTA San Andreas/moonloader/
```

For example:

```text
C:\Games\GTA San Andreas\moonloader\vst_background_selector.lua
```

Your folder should look similar to:

```text
moonloader/
│
├── vst_background_selector.lua
├── lib/
│
└── ...
```

---

# ▶️ Running the Script

1. Start GTA San Andreas.
2. Launch SA-MP.
3. Connect to your server.
4. MoonLoader automatically loads the script.
5. Check the SA-MP chat.

You should see:

```text
[VST] Background selector loaded. Created by Saifeddine Ben Salem.
```

This is the **only script-generated message** intentionally displayed in the SA-MP chat.

---

# 🎮 Usage

## Open the Vehicle Suggestions

Press:

```text
T
```

Then type:

```text
/vst
```

The available vehicles will appear below the chat input.

---

## Select Vehicle Slot 1

Type:

```text
/vst 1
```

and press Enter.

The first vehicle is selected automatically.

---

## Select Vehicle Slot 2

```text
/vst 2
```

---

## Select Vehicle Slot 3

```text
/vst 3
```

---

## Select Any Vehicle

For example, if the server displays six vehicles:

```text
/vst 6
```

selects the sixth vehicle.

---

# 🌐 Server Compatibility

The script is designed for **SA-MP roleplay servers and other servers that implement a compatible Vehicle Storage dialog**.

It can potentially work with:

- Horizon Roleplay
- Other SA-MP RP servers
- Custom RP servers
- Freeroam servers
- Economy servers
- Other servers using a compatible `/vst` Vehicle Storage system

### Important

The script is **not hard-coded to one specific server**.

Compatibility depends on how the server implements its `/vst` dialog.

The script reads the server's actual Vehicle Storage dialog dynamically instead of using a fixed vehicle list.

---

# 🏎️ Compatible Dialog Example

The script was designed around Vehicle Storage dialogs similar to:

```text
Vehicle storage (empty slots available: 2)

1: Vehicle: BF-400 | Status: Stored | Location: Glen Park
2: Vehicle: Broadway | Status: Stored | Location: Pershing Square
3: Vehicle: BMX | Status: Stored | Location: Glen Park
4: Vehicle: Bullet | Status: Stored | Location: Pershing Square
5: Vehicle: Benson | Status: Stored | Location: Ocean Docks
6: Vehicle: FCR-900 | Status: Stored | Location: Willowfield
```

The script reads these rows and stores the vehicle information internally.

---

# ⚙️ Configuration

The main visual configuration options are near the beginning of the Lua file.

## Font Size

The current font is:

```lua
local font =
    renderCreateFont(
        "Arial",
        11,
        5
    )
```

To make the text larger, increase `11`.

Example:

```lua
local font =
    renderCreateFont(
        "Arial",
        13,
        5
    )
```

---

## Vertical Position

The selector currently uses:

```lua
local LIST_Y_OFFSET = 8
```

Increase the value to move the list further down.

Example:

```lua
local LIST_Y_OFFSET = 15
```

Decrease it to move the list upward.

Example:

```lua
local LIST_Y_OFFSET = 3
```

---

## Horizontal Position

The current value is:

```lua
local LIST_X_OFFSET = 0
```

Move the list to the right:

```lua
local LIST_X_OFFSET = 20
```

Move it to the left:

```lua
local LIST_X_OFFSET = -10
```

---

## Line Height

The current spacing is:

```lua
local LINE_HEIGHT = 21
```

Increase it if you want more space between vehicles:

```lua
local LINE_HEIGHT = 24
```

---

## Maximum Visible Vehicles

The current maximum is:

```lua
local MAX_VISIBLE = 12
```

For example:

```lua
local MAX_VISIBLE = 20
```

allows up to 20 suggestions to be rendered.

---

# 🧠 How It Works

The script uses MoonLoader, SA-MP event hooks, FFI and SA-MP rendering functionality.

## 1. Detecting the Chat Input

The script checks:

```lua
sampIsChatInputActive()
```

to determine whether the player has opened the SA-MP chat input.

---

## 2. Reading the Input

It reads:

```lua
sampGetChatInputText()
```

and checks whether the player is typing:

```text
/vst
```

---

## 3. Reading the Real Chat Position

Instead of assuming that the chat input is always located at a fixed screen coordinate, the script accesses the SA-MP input structure.

It reads the actual:

```text
dwPosChatInput[0]
dwPosChatInput[1]
```

coordinates.

This allows the vehicle list to follow the actual SA-MP chat input position.

---

## 4. Retrieving the Vehicle List

When necessary, the script requests:

```text
/vst
```

and receives the server's Vehicle Storage dialog.

The script reads the dialog rows and stores the vehicle information.

The automatic dialog request is hidden from the player.

---

## 5. Rendering the Suggestions

The vehicles are rendered using MoonLoader's:

```lua
renderFontDrawText()
```

No background rectangle is drawn.

---

## 6. Automatic Slot Selection

When the player enters:

```text
/vst 4
```

the process is:

```text
/vst 4
   ↓
Intercept command
   ↓
Request /vst
   ↓
Receive VST dialog
   ↓
Read vehicle rows
   ↓
Find row 4
   ↓
Select row 4
   ↓
Close dialog
```

The selection itself does not generate a script-created SA-MP chat message.

---

# 🔐 Server-Side Behavior

This script does not modify the server.

The actual vehicle spawning and storage operation remains controlled by the server.

The script does not:

- Create unauthorized vehicles
- Change vehicle ownership
- Modify player money
- Modify server databases
- Bypass server-side vehicle storage
- Alter server files

It works with the normal SA-MP command and dialog system exposed to the client.

> **Important:** Server rules always take priority. Only use client-side scripts where the server permits them.

---

# 🐛 Troubleshooting

## Vehicle List Doesn't Appear

Check that:

1. MoonLoader is installed.
2. The `.lua` file is inside:

```text
GTA San Andreas/moonloader/
```

3. MoonLoader is running.
4. You are connected to the server.
5. The server supports `/vst`.
6. The server uses a compatible Vehicle Storage dialog.

---

## `/vst` Opens Normally but Suggestions Don't Appear

Try opening the VST menu manually:

```text
/vst
```

Then close it.

Press `T` again and type:

```text
/vst
```

The script should be able to use the captured Vehicle Storage information.

---

## Text Is Too High or Too Low

Modify:

```lua
local LIST_Y_OFFSET = 8
```

For example:

```lua
local LIST_Y_OFFSET = 12
```

moves it lower.

---

## Text Is Too Small

Change:

```lua
"Arial",
11,
5
```

to:

```lua
"Arial",
13,
5
```

---

## Only Some Vehicles Appear

Increase:

```lua
local MAX_VISIBLE = 12
```

For example:

```lua
local MAX_VISIBLE = 20
```

---

## `/vst` No Longer Opens the Server Dialog

Make sure you are using the latest version of the script.

Normal `/vst` behavior is intentionally preserved.

The script only intercepts the numeric format:

```text
/vst 1
/vst 2
/vst 3
```

while a normal:

```text
/vst
```

is passed through to the server.

---

# 📁 Recommended Repository Structure

```text
VST-Background-Slot-Selector/
│
├── README.md
│
├── vst_background_selector.lua
│
├── LICENSE
│
└── screenshots/
    ├── vst-suggestions.png
    └── vst-menu.png
```

---

# 📜 License

You are free to:

- Use the script
- Modify the script
- Improve the script
- Fork the project
- Create pull requests
- Adapt it for compatible SA-MP servers

Please keep the original author credit when redistributing substantial portions of the project.

---

# 👤 Author

## Saifeddine Ben Salem

Creator and developer of **VST Background Slot Selector**.

The project was created to improve the usability and speed of Vehicle Storage systems in SA-MP.

---

# 🏆 Credits

**Creator:**

> Saifeddine Ben Salem

**Technologies:**

- Lua
- MoonLoader
- SA-MP
- GTA San Andreas
- FFI
- SA-MP Dialog API
- MoonLoader Rendering API

---

# 🚀 Future Improvements

Potential future features:

- [ ] Mouse selection
- [ ] Keyboard arrow navigation
- [ ] Enter to select highlighted vehicle
- [ ] Tab completion
- [ ] Advanced vehicle-name search
- [ ] Location filtering
- [ ] Vehicle status filtering
- [ ] Favorite vehicles
- [ ] Custom text colors
- [ ] Custom fonts
- [ ] Configurable position
- [ ] Configurable transparency
- [ ] Multiple VST dialog formats
- [ ] Automatic server detection
- [ ] `/vst [vehicle name]`
- [ ] `/vst bullet`
- [ ] `/vst glen park`
- [ ] Scrollable vehicle list
- [ ] Fully customizable UI

---

# 💡 Example Workflow

Imagine your Vehicle Storage contains:

```text
1  BF-400
2  Broadway
3  BMX
4  Bullet
5  Benson
6  FCR-900
```

Press:

```text
T
```

and type:

```text
/vst
```

The script displays:

```text
1  BF-400
2  Broadway
3  BMX
4  Bullet
5  Benson
6  FCR-900
```

You can then type:

```text
/vst 4
```

and press Enter.

The script automatically selects:

```text
4  Bullet
```

without requiring you to manually navigate the Vehicle Storage dialog.

---

# ❤️ Why This Script Exists

SA-MP roleplay servers often require players to repeatedly open vehicle-storage menus just to determine which vehicle is stored in a particular slot.

This script brings that information directly into the chat interface.

Instead of:

```text
/vst
   ↓
Open dialog
   ↓
Find vehicle
   ↓
Close dialog
   ↓
Type command
```

you can simply:

```text
/vst
   ↓
See vehicles immediately
   ↓
/vst 4
```

Simple, fast and lightweight.

---

<p align="center">

## 🚗 Made for the SA-MP Community

### VST Background Slot Selector

**Created by Saifeddine Ben Salem**

</p>
