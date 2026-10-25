# My Caelestia + Hyprland desktop

These are the settings from my Arch Linux desktop, with four wallpapers included. Install Caelestia first, then copy these files into your home folder. Back up your existing settings before copying.

## Install

1. Install Caelestia using its [official instructions](https://github.com/caelestia-dots/caelestia).
2. Install the terminal programs used by these settings:

   ```sh
   sudo pacman -S --needed foot fish fastfetch
   ```

   For animated wallpaper changes, also install Awww and Pillow:

   ```sh
   sudo pacman -S --needed awww python-pillow
   ```

3. On GitHub, select **Code → Download ZIP** and extract it. You do not need a GitHub account, Git setup, or a Git email to install these files.
4. Open a terminal in the extracted folder and copy the settings and included images:

   ```sh
   mkdir -p ~/.config ~/.local ~/Pictures/Logo ~/Pictures/Wallpapers
   cp -a dotfiles/.config/. ~/.config/
   cp -a dotfiles/.local/. ~/.local/
   cp -a assets/Pictures/Logo/. ~/Pictures/Logo/
   cp -a assets/Pictures/Wallpapers/. ~/Pictures/Wallpapers/
   ```

5. Reload Hyprland with `hyprctl reload`, then restart Caelestia with **Ctrl+Super+Alt+R**.

The included wallpapers are `0019.jpg`, `0028.jpg`, `Space-Nebula.png`, and `Fantasy-Autumn.png`. You can put more images in `~/Pictures/Wallpapers`.

## Change the personal bits

Open the files below in a text editor and change the value shown.

| What to change | File | Setting |
| --- | --- | --- |
| Terminal greeting/name | `dotfiles/.config/fastfetch/config.jsonc` | Change `Welcome back, user` to your preferred text. |
| Terminal window title | `dotfiles/.config/foot/foot.ini` | Change `title=foot`. |
| Terminal or browser opened by shortcuts | `dotfiles/.config/hypr/variables.lua` | Change `terminal = "foot"` or `browser = "zen-browser"`. These are the programs opened by **Super+T** and **Super+W**. |
| Browser used by Caelestia | `dotfiles/.config/caelestia/hypr-vars.lua` | Set `browser` to the same browser command as above. |
| Image shown in the terminal | `dotfiles/.config/fastfetch/config.jsonc` | Change `logo.source`; the included image is `~/Pictures/Logo/ben.png`. |
| Logo at the top-left of the bar and dashboard | `dotfiles/.config/caelestia/shell.json` | Change `general.logo`; the included image is `~/Pictures/Logo/ben-bar-large.png`. |

To use your own logos, copy the images to `~/Pictures/Logo` and update the matching path above. The original images are in `assets/Pictures/Logo`.

Other useful settings: change your monitor in `dotfiles/.config/hypr/hyprland-gui.lua` (the current setting is `DP-1` at `1920x1080@240Hz`), and change the cursor in `dotfiles/.config/caelestia/hypr-vars.lua`.

Some Quickshell files use Caelestia files under `/etc/xdg/quickshell/caelestia`. Install Caelestia first. If your system stores those files elsewhere, update the links in `dotfiles/.config/quickshell/caelestia`.

## Credits

The desktop is based on [Caelestia](https://github.com/caelestia-dots/caelestia). The included Discord themes come from [Midnight](https://github.com/refact0r/midnight-discord). See [LICENSE](LICENSE) for license details.
