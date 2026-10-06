# ax's NixOS & Niri Configuration Dotfiles

Welcome to my personal NixOS configuration repository, custom-built for the **Asus X555LAB** laptop powered by an **Intel Core i3** processor. 

This repository provides a functional, basic setup centered around the **Niri** scroll-able-tiling window manager. Crucially, it includes a dedicated, out-of-the-box fix for the notorious **MediaTek MT7630E** combo chip, ensuring stable, native performance for both **Wi-Fi** and shared **Bluetooth**.

All files and architectural designs in this repository have been created and are maintained by **ax** (ax@slackware.eu). For real-time chat, join the community on **irc1.slackware.eu SLK - UmbrellaNet** inside the **#lug** channel.

---

## 💻 Target Hardware Specs
* **Device:** Asus X555LAB
* **CPU:** Intel(R) Core(TM) i3 Processor
* **Wireless Chipset:** MediaTek MT7630E (Combo Wi-Fi & Bluetooth)

---

## 🛠️ The MT7630E Fix (Wi-Fi & Bluetooth)
The MediaTek MT7630E chip is historically difficult to get working properly on modern Linux distributions. This repository solves the problem natively within NixOS by separating the implementation into two modular declarations:
* **`mt7630e.nix`**: Patches and loads the necessary kernel modules and firmware required to stabilize the Wi-Fi connection.
* **`mt7630e-bluetooth.nix`**: Manages the initialization scripts and shared interface configs required to firmware-load and activate the Bluetooth component seamlessly alongside the wireless driver.

---

## 📁 Repository Structure & Files

| File / Folder | Description |
| :--- | :--- |
| `config/` | Contains the core configuration files for the **Niri** window manager (layout, keybindings, and basic window rules). |
| `wallpapers/` | A collection of system wallpapers used across the desktop environment. |
| `configuration.nix` | System-level configuration file mapping out system packages, user configurations, boot parameters, and basic services. |
| `hardware-configuration.nix` | Hardware scan outputs containing file systems, boot options, and baseline kernel modules for the Asus X555LAB. |
| `mt7630e.nix` | The customized Nix expression handling the wireless driver compile-hooks and kernel patches for the MT7630E. |
| `mt7630e-bluetooth.nix` | The companion Nix module resolving firmware and initialization issues for the shared MT7630E Bluetooth core. |

---

## 🚀 Getting Started & Installation

### 1. Clone the Repository
Clone these dotfiles directly into your NixOS configuration directory:
```bash
git clone https://github.com
cd nixOS-NIRI-dots
```

### 2. Integrate with your system
Copy or link these files into `/etc/nixos/`, ensuring both `mt7630e.nix` and `mt7630e-bluetooth.nix` are imported directly inside your main `configuration.nix` array:
```nix
imports = [
  ./hardware-configuration.nix
  ./configuration.nix
  ./mt7630e.nix
  ./mt7630e-bluetooth.nix
];
```

### 3. Rebuild NixOS
Apply the changes and switch over to your new Niri desktop environment:
```bash
sudo nixos-rebuild switch
```

---

## 🪪 License

This project is licensed under the **MIT License** - see the `LICENSE` file for details. Copyright (c) 2026 ax.

---

## 💬 Contact & Community Support

If you have questions, patches, or need support regarding this setup, feel free to drop by or reach out:
* **Author:** ax
* **Email:** [ax@slackware.eu](mailto:ax@slackware.eu)
* **IRC Network:** `irc1.slackware.eu` (SLK - UmbrellaNet)
* **IRC Channel:** `#lug`
