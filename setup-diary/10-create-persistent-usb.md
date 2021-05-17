<!-- markdownlint-disable MD041 -->
## Part 1: Create Persistent Arch USB

- I think I can use GParted for this

  - Should I use the TUI version of it, to get some practice for later in the install?

  - Is that...`cparted`?

- It is `cgdisk`

  - Which is a TUI version of ~~`fdisk`~~ `gdisk`

- Ahh, when I say TUI I think I'm thinking of Curses

- I've deleted all the partitions currently on my 8GB flash drive

- Now I'm trying to copy the example layout from the Arch Wiki: <https://wiki.archlinux.org/title/Partitioning#Example_layouts>

- The first partition is an EFI System Partition (ef00 is its code in `cgdisk`), of at least 260 MiB

  - I have a vague memory of that not being enough space for GRUB?

  - Ehh, seems to be fine, we'll cross that road when we get to it

- I have:

  - EFI System Partition, 260M

  - SWAP, 1G

  - root, ~6G (all remaining space)

- Now I need to format the partitions

- The EFI partition must be FAT32

  - `sudo mkfs.fat -F32 /dev/sdb1`

- Swap has slightly different syntax for some reason

  - `sudo mkswap /dev/sdb2`

- And finally, good ol ext4

  - `sudo mkfs.ext4 /dev/sdb3`

- Then mounting them all on my local filesystem with:

  - `sudo mount /dev/sdb3 /mnt`

  - `sudo mkdir /mnt/efi`

  - `sudo mount /dev/sdb1 /mnt/efi`

  - `sudo swapon /dev/sdb2`

- (I skipped the "select mirrors" part of this process, because it is tedious and I already did it once a few years ago)

  - Future Aileen here: I'm not sure that I ever actually copied my mirrors file over though...

- And finally, installing the basics (and a few of my own goodies) with:

  - `sudo pacstrap /mnt base linux linux-firmware vim man-db man-pages texinfo`

- Next up, generating the `fstab` file. I had to explicitly switch to `root` for this one, `sudo` doesn't work because the target system doesn't know about my rules.

  - `genfstab -U /mnt >> /mnt/etc/fstab`

- Now for the most fun part: chrooting!

  - `arch-chroot /mnt`

- Some good news - whatever I've done was at least enough to run `pacman`.

- I immediately installed the packages `grub` and `efibootmgr` - I think I need them to install GRUB

- I'm following this bit of the guide for installing GRUB:

  - <https://wiki.archlinux.org/title/GRUB#UEFI_systems>

- Hmm, I got something wrong on my first attempt at the command:

  - `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB`

- It says:

```bash
Could not delete variable: Invalid argument
grub-install: error: efibootmgr failed to register the boot entry: Block device required.
```

- What...does that mean?

- Arg, I think I need to mount the boot partition...

  - No, it is already mounted at `/efi`

- Oh, I think that error might be because I'm using the `/efi` directory, and *might* not matter.

- I was able to run the command `grub-mkconfig` without any issue, and the necessary files were put in `/efi/EFI/GRUB/grubx64.efi`

- Oh, maybe I should re-do the GRUB install and re-generate the config...I missed the likely necessary flag `--removable`

- That is certainly doing a lot more...

- It finished with "no error reported." So I'm happy!

- Now to re-gen the config

- Ahh, apparently I should do it for BIOS boots as well, to make this more portable

- Although...I'm curious if it is far enough along to boot now?

- I think I might need to make a partition bootable

  - Apparently, marking a partition "bootable" is particular to MBR...so I might need to do so at some point for portability, but it probably isn't immediately necessary.

    - <https://superuser.com/questions/1187219/why-i-dont-have-bootable-in-cgdisk>

    - Also, that is why I couldn't make it bootable in the GPT-specific `cgdisk` - that option *is* available in `fdisk` and its curses compatriot.

- I tried rebooting into the USB...I dunno if it failed completely or not, but it certainly didn't work.

  - I was dropped into a GRUB command line, after selecting the USB device (which showed up in my boot manager as UEFI, which is sorta promising)

  - The question is, was that just the version of GRUB installed on the laptop itself, failing to boot?

- I guess I might need to set up my beefy laptop somewhere else so I can try booting on it to ensure portability

---

@import "./11-documentation-detour.md"

---

- Alright, back to troubleshooting the boot media

- Gonna put my big laptop on ~~a table somewhere~~ my bed...

- Good news - it is booting to the GRUB CI on the USB, when I select it in the boot menu

- Bad news - I think this is about where I quit last time.

  - But I've paced myself better and I'm taking notes this time!

- [I ignored a warning in the "configure GRUB" section, here's the solution that was immediately after the warning](https://bbs.archlinux.org/viewtopic.php?pid=1225067#p1225067)

- The gist was "remount everything" (I mounted the EFI system partition to `/mnt/efi` rather than the suggested `/mnt/boot`), then `chroot` back in

  - Once inside, I remade my config file, explicitly specifying an output directory this time

  - `grub-mkconfig -o /boot/grub/grub.cfg`

- That definitely spit out some different stuff this time around

- Guess it is time to give it another try!

- Woot woot, I got my arch USB to boot!

  - It...immediately failed, but it got past grub

- It is failing almost immediately into the startup process, on the error ""

  - Welp, I spoke too soon, it just sat on *some* error message about saving the backlight settings...

  - I went to look and copy the error message, and it had dropped me into the login screen since I last checked

  - I'd like to know what that was about (and resolve it), but it seems unimportant for now

- Since I know it boots, I guess the next best course of action is...chrooting in and installing additional packages?

- I can't base my USB's packages on the existing laptop install, because it is bursting with cruft and probably exceeds the available space

  - Once I get the USB working consistently, I'll want to export all the packages that were necessary to do so into a list that goes in this repo (and probably an install script)

- Alright, the USB has been moved back to my Arch laptop for chrooting

- First things first, I need to set up some basic stuff like a user...

  - Heck, I've gotta give the root user a password

  - I always forget how to do this basic-ass stuff

- That was easy-peasy, with the command `passwd root`

- Now, to create a user...I know there is a `useradd` command

- Well, before I go and make a user, I can set up my `wheel` group

- This'll pretty much be a matter of copy-pasting what is in my current system's sudoers file

- Oh yeah, it is a matter of uncommenting a line in the default sudoers file

  - Which is edited, of course, with the command `visudo` (must be root, as it'll warn you)

- LOL, I tried to run `visudo` and it didn't work because there's nothing at `/usr/bin/vi`

  - I know I installed Vim, I'm surprised vi doesn't come along for the ride

  - I installed it, I'd prefer not to mess with root's default editor right now

    - And maybe it is best to keep root using the slimmest possible version?

- The line that must be uncommented is (for me):

  - `%wheel ALL=(ALL) ALL`

- Oh SNAP, in the process of doing this I accidentally messed up my local sudoers file

  - Ahh, phew, `visudo` validates the changes when you quit the editor, it just didn't accept the garbage I pasted in there

- Back on track, I uncommented the lined in the chroot's sudoers

  - Now I can immediately add my newly created user to that group

  - What other groups does my current install user belong to? I seem to recall there being audio groups and such

    - `games wheel audio essays docker`

      - I'll add myself to the `docker` group if/when I install Docker

      - `essays` is a group I made to share a directory between two users and isn't necessary

      - I prefer to use `wheel` over `sudo` as my sudoers group name, for a reason I've forgotten

- I'm also gonna install `zsh` before setting up my non-root user, because I can specify that as their shell during user creation

  - God bless the website `cheat.sh`, which I'm using to look up `useradd` examples

  - I should set up my alias for curling that site in the new user ASAP!

- I made my user, gave them a home, set their shell, and...forgot to add them to wheel on the first pass

  - Easy fix though!

  - ...Once I remembered the command to modify an existing user, `usermod`

- Hmm, reading the docs for usermod showed me the `-l` option to change a user's name, might as well use that on this laptop's install to make it a bit more pleasant to use before it gets nuked...

---

@import "./12-deadname-detour.md"

---

- All in all, the commands to set up the user were:

```bash
useradd --create-home --shell /usr/bin/zsh aileen
passwd aileen
usermod -a -G wheel,games,audio aileen
```

- I think this is the point at which I need to re-do my dotfiles enough to push them to git, so I can just clone them in the USB device

---

@import "./13-dotfile-detour.md"

---

- Now that my dotfiles are in git, I should set up git in the USB device

- Hmm, I installed `stow` and `git`, and the latter complained about my local settings. Seems I don't have a language set!

- I recall that being fairly simple, I think I just have to uncomment a line somewhere

- I need to set up an SSH key for my USB user

  - That requires installing the package `openssh`

  - Then, it is necessary to run the command `ssh-keygen`

- I added the persistent USB's git key to GitHub

- I'm not sure, but I think the USB has the same name as the host (my old laptop)

  - I guess I'll be able to check a bit better on my laptop

- Speaking of checking on my laptop, I should get networking working with wifi...which I know is a horrible pain

- Anyway, I got my dotfiles cloned into the USB

- I also successfully stowed my .zsh stuff

  - Then I realized I don't actually have oh-my-zsh installed...
  
  - Following my [usual guide](https://medium.com/wearetheledger/oh-my-zsh-made-for-cli-lovers-installation-guide-3131ca5491fb), I also had to install `curl`

    - The pertinent command is `sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`, which has a typo in the guide

- The Oh-My-Zsh install went without a hitch!

  - Well, it renamed my stowed file and made its own `.zshrc`, but that was easy to undo

- Now my persistent USB has the pretty prompt and plugins I expect!!

  - Blessed autocomplete...

  - Actually, I still have to install the plugins, which requires cloning some repos

  - I would also like to tweak my prompt slightly

    - That tweak can be added to my dotfiles, I think

- Oh-my-Zsh plugins are installed to `~/.oh-my-zsh/custom/plugins`

- The commands I ended up needing to run were:

  - `git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`

  - `git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`

- I'm sick of re-mounting the device over and over again, so I am going to write a lil script that does it

- I just installed a package called `shellcheck` (in the laptop, for now) that integrates with a VS Code plugin of the same name

  - It immediately caught an issue in the shebang, so it was a worthwhile install!

- I might've gone a bit overkill on the script, but it was good practice!

  - And now working on this is a breeze...? \</sarcasm>
  
  - I guess the script will be handy for mounting targets devices, once the newly named LiminalArch starts doing installs instead of receiving them

  - As a side thought, if I start to run out of space on this device I can just use it to set up a bigger one!

- Back to the install itself!

- I'm realizing that my mounting script is one tiny sliver of my list of scripts below needed for automating this, so that's cool

- Hmm, locale, that's something in need of doing

  - [V Easy](https://wiki.archlinux.org/title/Installation_guide#Localization)

  - I ended up making it a bit more complex for myself by figuring out how to uncomment the line from `/etc/locale.gen` with `sed`

    - Another little bit of future scripting ready to go!

    - Sources:

      - <https://www.reddit.com/r/linuxquestions/comments/bo7kd3/how_to_use_sed_to_change_uncomment_the_second/>

      - <https://stackoverflow.com/questions/24889346/how-to-uncomment-a-line-that-contains-a-specific-string-using-sed/24889374>

  - Commands I did:

```bash
# Put this in a script with some variables...
sed -i '1,/en_US.UTF-8 UTF-8/!{s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/}' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

- I already did the very next thing on the list, but for completeness of the guide I should include creating the hostname file

  - Plus the hosts, which I *hadn't* done yet

```bash
echo "LiminalArch" >> /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 LiminalArch.localdomain LiminalArch" >> /etc/hosts
```

- I'm now at the actual end of the Installation Guide

  - I think the line is pretty blurred, but whatev

  - Now it is time to move on to General Recommendations!

- **TODO: Copy over my existing pacman mirrors file**
