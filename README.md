# Caelestia + Hyprland setup

These are my personal settings for an Arch Linux desktop using Hyprland and Caelestia. They customize the launcher, notifications, quick settings, cursor, keybinds, and wallpaper animations.

This repository adds my settings on top of Caelestia. It is not a complete Linux installer. Back up your current settings before copying anything.

## Install the programs

On Arch Linux, install Caelestia using its [official instructions](https://github.com/caelestia-dots/caelestia). The usual steps are:

```sh
paru -S caelestia-cli
caelestia install
```

For the animated wallpaper effect, also install Awww and Pillow:

```sh
sudo pacman -S --needed awww python-pillow
```

You can skip Awww if you do not want animated wallpaper changes. The rest of the desktop still works.

## Copy these settings

1. Download or clone this repository.
2. Back up `~/.config` and `~/.local`.
3. Open a terminal in this repository and copy the files:

```sh
mkdir -p ~/.config ~/.local ~/Pictures/Logo
cp -a dotfiles/.config/. ~/.config/
cp -a dotfiles/.local/. ~/.local/
cp -a assets/Pictures/Logo/. ~/Pictures/Logo/
```

4. Restart Caelestia by pressing **Ctrl+Super+Alt+R**.

The wallpaper images are not included here. Put your own images in `~/Pictures/Wallpapers`.

Some Quickshell files link to Caelestia's installed files at `/etc/xdg/quickshell/caelestia`. Install Caelestia first. If those files are somewhere else on your system, the links need to be changed to match.

## Change the settings

- **Monitor:** Edit `dotfiles/.config/hypr/hyprland-gui.lua`. It currently says `DP-1` and `1920x1080@240Hz`; use your monitor's name and resolution.
- **Apps and shortcuts:** Edit `dotfiles/.config/hypr/variables.lua`. For example, `Super+W` opens Zen Browser. Change the app names if you use different programs.
- **Cursor:** Edit `dotfiles/.config/caelestia/hypr-vars.lua`.
- **Logo:** Change the `logo` entry in `dotfiles/.config/caelestia/shell.json`, or replace the logo in `~/Pictures/Logo`.
- **Colors and themes:** The app theme files are under `dotfiles/.config`.

## Git name for this repository

In this copy of the repository, the Git author name is set to `user`. Git keeps this setting inside the local `.git` folder, so it does not change your Linux login, terminal greeting, or other repositories. People who clone this repository set their own author details.

To choose a different author name for this repository, open a terminal in its folder and run:

```sh
git config user.name "Your Name"
```

Git also needs an author email. To link commits to your GitHub account without showing your personal email, copy the `noreply` address from GitHub **Settings → Emails**, then set it for this repository:

```sh
git config user.email "your-github-noreply-address"
```

## Credits

The Caelestia customizations are based on [Caelestia](https://github.com/caelestia-dots/caelestia). The included Discord theme files come from [Midnight](https://github.com/refact0r/midnight-discord). See `LICENSE` for license details. Wallpaper images stay in the local bundle because their redistribution terms have not been checked.
