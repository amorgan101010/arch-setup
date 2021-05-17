<!-- markdownlint-disable MD041 -->
## TODO

- Add dates to this document

  - And maybe split the parts into separate files

- [Add Gnome Tweaks and themes to Dotfiles repo](https://unix.stackexchange.com/questions/426322/how-do-i-use-the-plain-text-mode-of-dconf/426348#426348)

- Fix any errors during the USB's boot

- Figure out a way to add my VS Code extensions to my dotfiles

- Figure out how to use a better config path for the version of VS Code that's available in the Community package repo

  - Right now it is `Code - OSS` with a space!

- ~~USB Networking with WiFi~~

- ~~USB GUI!~~

  - Might be a squeeze, I've only got 3.6G free and I've still gotta install most things

  - Nah, Gnome is fine ("fine")

- Craft a script that does everything I've described to a given device (`install.sh`)

  - ~~Make one that partitions the device (`partition-device.sh`)~~

    - In progress, probably gonna be tricky
  
  - ~~One that sets up the filesystems (`format-device.sh`)~~

    - Easy, assuming correct input

    - ~~Not actually tested...~~

  - ~~Another that mounts the newly set up partitions~~ (`mount-device.sh`)

    - This script is also handy for re-mounting a device that was set up by the installer!

  - ~~Another that does the pacstrapping, but with all the packages I've described in one go (if that is possible without errors)~~

    - Ended up doing it in multiple passes to save time

  - ~~Yet another for setting up GRUB for at least GPT~~

    - I don't think I even have a device to test MBR on...

  - ~~One that sets up groups and makes a user~~

  - ~~Then one that clones my dotfiles, installs Oh My Zsh, and stows everything~~

  - ~~One that sets up locale~~
