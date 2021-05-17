<!-- markdownlint-disable MD041 -->
### Design Detour: Learning a bit about GNOME

- I'm on a terribly unfocused detour, installing a slimmer toolbar in my current laptop

  - Not worth the space for the installer

  - Well, it's only 4M...but it's also just some random "cool ranch guy" who made it

- I think the laptop might be missing whatever package allows for Gnome UI tweaking...

  - The appropriately named gnome tweak tool

    - `gnome-tweaks`

    - It is also quite small, 1M

  - Apparently it has been superseded by GNOME Extensions (`gnome-shell-extensions`)

    - This is why people complain about GNOME, I think

- Gnome Shell Extensions immediately made my mouse unusable for anything other than clicking a balloon popped up...

  - I had to go to a TTY and kill it

  - I...don't really feel good about using it now

    - It was very bad seeming, in the way that "app/extension stores" in Linux usually are

- I went back to `gnome-tweaks`, and the AUR theme `gtk-theme-minwaita`

  - Specifically, the Dark OSX option. Much better!

- It seems that making my installer automatically use the Dark OSX theme is harder than I thought...

  - GNOME tweaks are stored in a binary database located in `~/.config/dconf`

  - [I found a thread about exporting that to a text file that can be synced](https://unix.stackexchange.com/questions/426322/how-do-i-use-the-plain-text-mode-of-dconf/426348#426348)

    - Seems more like a future task, once the essentials are scripted out