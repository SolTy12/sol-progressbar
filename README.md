# 🌟 Universal FiveM Progressbar

A sleek, lightweight, and modern progress bar for FiveM servers. Designed for **absolute universal compatibility**, this script seamlessly integrates into any framework—whether you're using **QBCore**, **ESX**, or a custom framework—without requiring you to modify your existing scripts.

![Showcase Image](<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/240420cc-4311-434a-b24e-c3532513f1f1" />
)
![Showcase Image] <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/bfaeb072-3feb-440c-8b90-c82486f3cebc" />


## ✨ Features

- **Universal Framework Support**: Natively understands and automatically intercepts QBCore (`qb-progressbar`), ESX (`esx_progressbar`), and Mythic (`mythic_progbar`) logic.
- **Zero Configuration Integration**: Simply start the script, and it will immediately replace the visual interface of existing progress bars across your entire server. 
- **Standalone**: Does not natively depend on QBCore or ES_extended, making it the perfect choice for custom environments or servers transitioning between frameworks.
- **Modern UI**: Clean and minimalistic design, providing players with clear and polished visual feedback.
- **Event & Export Driven**: Easily trigger the progress bar using direct exports or native network events.

## 🎯 Who is this for?

- **Server Owners** tired of matching different progressbars for different scripts and frameworks.
- **Developers** looking for a robust, drop-in replacement that handles edge-case parameter typings automatically.
- Anyone moving from ESX to QBCore (or vice versa) wanting a consistent UI across their scripts without rewriting events.

---

## 🛠️ Installation

1. **Download** the latest release from the repository.
2. Extract the folder into your server's `resources` directory (e.g., `[standalone]`).
3. Ensure the folder is named **`progressbar`**.
4. Add the following line to your `server.cfg` file **before** starting QBCore or ESX dependencies:
   ```cfg
   ensure progressbar
   ```
5. *(Optional)* If you have an existing `qb-progressbar` or `esx_progressbar` folder, **delete or disable them** to prevent duplication and conflicts.

---

## 📖 Usage for Developers

You can use either **Exports** or **Events**. Both approaches smartly translate different argument structures, allowing seamless drag-and-drop workflow.

### Option 1: The Modern Table Strategy (via Export)

```lua
exports['progressbar']:Progressbar({
    name = "fixing_engine",
    label = "Repairing Engine...",
    duration = 5000,
    useWhileDead = false,
    canCancel = true,
    controlDisables = {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    },
    animation = {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 49,
    },
    prop = {
        model = "prop_tool_wrench",
        bone = 28422,
        coords = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    }
}, function(cancelled)
    if not cancelled then
        print("Action Finished")
    else
        print("Action Cancelled")
    end
end)
```

### Option 2: ESX Style Format Events

```lua
TriggerEvent('esx_progressbar:start', "Doing something...", 5000, {
    useWhileDead = false,
    can_cancel = true,
    freeze = true,
    onFinish = function()
        print("Finished!")
    end,
    onCancel = function()
        print("Cancelled!")
    end
})
```

---

## 🤝 Compatibility Triggers

The system automatically registers and translates the following common triggers natively:
- `QBCore.Functions.Progressbar` (Both positional and table implementations)
- `exports['qb-progressbar']:Progressbar`
- `exports['mythic_progbar']:Progress`
- `TriggerEvent('progressbar:client:progress')`
- `TriggerEvent('esx_progressbar:start')`

## 💬 Support & Contributing

If you encounter any bugs or have feature requests, please open an Issue or a Pull Request on GitHub. Contributions are highly welcomed!
