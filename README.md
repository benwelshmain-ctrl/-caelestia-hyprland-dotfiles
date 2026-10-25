# Caelestia + Hyprland setup

These are my personal settings for an Arch Linux desktop using Hyprland and Caelestia. They customize the launcher, notifications, quick settings, cursor, keybinds, and wallpaper animations.

This repository adds my settings on top of Caelestia. It is not a complete Linux installer. Back up your current settings before copying anything.

## Get the files

On the GitHub page, choose **Code → Download ZIP**, then extract the ZIP. You do not need to sign in to GitHub or set up a Git name or email just to install these dotfiles.

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
mkdir -p ~/.config ~/.local ~/Pictures/Logo ~/Pictures/Wallpapers
cp -a dotfiles/.config/. ~/.config/
cp -a dotfiles/.local/. ~/.local/
cp -a assets/Pictures/Logo/. ~/Pictures/Logo/
cp -a assets/Pictures/Wallpapers/. ~/Pictures/Wallpapers/
```

4. Restart Caelestia by pressing **Ctrl+Super+Alt+R**.

The repository includes four wallpapers: `0019.jpg`, `0028.jpg`, `Space-Nebula.png`, and `Fantasy-Autumn.png`. Add any other wallpapers you want to `~/Pictures/Wallpapers`.

Some Quickshell files link to Caelestia's installed files at `/etc/xdg/quickshell/caelestia`. Install Caelestia first. If those files are somewhere else on your system, the links need to be changed to match.

## Change the settings

- **Monitor:** Edit `dotfiles/.config/hypr/hyprland-gui.lua`. It currently says `DP-1` and `1920x1080@240Hz`; use your monitor's name and resolution.
- **Apps and shortcuts:** Edit `dotfiles/.config/hypr/variables.lua`. For example, `Super+W` opens Zen Browser. Change the app names if you use different programs.
- **Cursor:** Edit `dotfiles/.config/caelestia/hypr-vars.lua`.
- **Logo:** Change the `logo` entry in `dotfiles/.config/caelestia/shell.json`, or replace the logo in `~/Pictures/Logo`.
- **Colors and themes:** The app theme files are under `dotfiles/.config`.

## Credits

The Caelestia customizations are based on [Caelestia](https://github.com/caelestia-dots/caelestia). The included Discord theme files come from [Midnight](https://github.com/refact0r/midnight-discord). See `LICENSE` for license details. Only the four wallpapers listed above are included; the rest of my local wallpaper collection is not tracked here.
