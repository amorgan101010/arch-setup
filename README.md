# Arch Setup

## Part 1: Create Persistent Arch USB

- I think I can use GParted for this

  - Should I use the TUI version of it, to get some practice for later in the install?

  - Is that...`cparted`?

- It is `cgdisk`

  - Which is a TUI version of ~~`fdisk`~~ `gdisk`

- Ahh, when I say TUI I think I'm thinking of Curses

- I've deleted all the partitions currently on the 8GB flash drive

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

### Documentation Detour: Setting up Git

- Might as well do this sooner rather than later

- Had to update my global git config to have the proper name and email

- Also, couldn't push for a minute from the command line...

  - I think it was because I hadn't actually committed this file yet

  - I ended up doing it all with VS Code, which was actually really easy

  - Turns out life is easiest working from a Unix system

  - Using GitHub in VS Code also probably helped, keeping it all in the family

- I also hadn't uploaded any SSH keys to my new Git account yet, which was as easy as copying my existing pub key into a settings window

- I can confirm that my issue with git on the command line was just because I hadn't added any files

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

### Deadname Detour: Name Changes in Unix

- Turns out, it is far easier than in real life.

```bash
usermod -l newname oldname
usermod -m -d /home/newname newname
```

- Some stuff seems to have been broken, though...

  - Oh-My-Zsh doesn't seem to be properly configured now

  - My custom new tab page's path had to be updated in the chrome extension

- I think I need to re-`stow` my dotfiles after moving home directories, but I've forgotten exactly how to do that

  - Perhaps I should...stop doing that

  - Or, redo it as part of this project

    - Yes!

  - But for now, I just want oh-my-zsh to work on my old install...

- It had nothing to do with `stow`, I had a hard-coded home path in my `.zshrc` file

  - I permanently fixed that by updating it to use the environment variable `$HOME`

- Now everything is working again!

- (the old username still shows up in an `ls -al`, not sure if that is fixable)

---

- All in all, the commands to set up the user were:

```bash
useradd --create-home --shell /usr/bin/zsh aileen
passwd aileen
usermod -a -G wheel,games,audio aileen
```

- I think this is the point at which I need to re-do my dotfiles enough to push them to git, so I can just clone them in the USB device

---

### Dotfile Detour: Return to Version Control

- I have an old copy of my dotfiles in an old GitHub repo, but I'd like to have a fresh and shiny version to actually maintain between multiple devices

  - It looks like I already removed the git-ness of the version on my old Arch laptop...

- I started at the top of the directories and immediately ran into trouble - it seems I've been editing a different version of my new tab page than what is in the dotfiles dir

- I think the definitive version of that is actually on my Windows PC, because it shuffles between a number of images

  - Heck, the version on Github might even be newer!

- Alright, just not gonna add that to the dotfiles repo for now...

- Not something to do immediately, but I should add my VS Code settings to the dotfiles repo as well

  - Probably once I get the dotfiles repo cloned to my work PC

- I deleted most of the stuff I had, because it is software I don't intend to use...but I'd like to keep it around, I guess

  - Some stuff was so broken I figured I didn't need to copy it at all, or there was a newer version to copy from elsewhere.

- [Here's the repo!](https://github.com/amorgan101010/dotfiles)

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

## Part 2: Make It Useable in a Modern sense

- I'm getting bored, so I will follow [a guide for installing GNOME](https://phoenixnap.com/kb/arch-linux-gnome)

  - I guess that could be considered K.I.S.S.

  - Best to do the boring but functional thing for now!

  - Since I have been *using* GNOME for a while, it only makes sense to start from there

```bash
# Install X Window System (all components)
pacman -S xorg xorg-server

# Install GNOME (all components, default sources)
pacman -S gnome
```

- I remember this part of the process being way way harder the first time around

  - probably because the Arch Wiki branches off down a thousand different paths when you want to do something like use i3 on top of XFCE with a custom greeter

  - Hence, GNOME

  - I'm rambling because installing GNOME is taking a hefty amount of time

- When I get to the part of all this where I make an install script, I'll probably want to use a local pacman repo

  - Then it is offline!

  - [Here's the wiki page about how to do it](https://wiki.archlinux.org/title/Offline_installation)

  - I'm not quite sure how to do that sort of thing fluently with pacman repos yet
  
    - I have a vague memory of setting up a local pacman repo for a package I built, so it would get updated with everything else

    - I know that is one of the benefits of pacman...

- While I wait, I guess I can work on the scripting

- Just as I was getting bored of scripting, the GNOME install finished!

- All that was left to do in the chroot was enabling the greeter with:

  - `sudo systemctl start gdm.service`

- I unfortunately discovered a new bug in the unmounting part of the mount script :/

- But, GNOME works perfectly on the first attempt!!

- Guess where I'm writing from?

  - Inside the USB!

  - I plugged in my PlayStation Ethernet...

- I am almost out of space on the installer, but I guess I'm also done with the big stuff

  - I would like to get `yay` up and running so I can install VS Code and Chrome

  - If anything is gonna fill up the rest of the space, it is that...

  - Hmm, just using the browser in the device immediately ate up the rest of the space

  - I should probably hold off on installing anything else until I can install to another device!

    - Alas, I have nothing bigger than 8G right now...

- On the bright side, GNOME seems to include the kitchen sink in a good way

  - Once I enabled and started Network Manager, I had both Wifi and Ethernet available (and even bluetooth!)

  - The inserted SD card also showed up, which I remember being much more painful to get working last time

- The commands to set up Networking:

```bash
sudo systemctl start NetworkManager.service
sudo systemctl enable NetworkManager.service
```

- I'll install `lynx` for all my browsing needs, that's only 7M...

- I immediately blew my space savings installing the build dependencies for Yay...

```bash
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
```

- I have 74M, better use em wisely

- I managed to free up a gig by clearing my pacman cache...not great for an installer, but I guess the whole "use the local cache" stuff can wait to be set up until there is a bigger USB.

  - Ugh, Yay is yet again eating up a sizeable chunk of that space with its Go dependency

    - Go is the second-largest thing in my whole install...

- The `makepkg -si` command was failing because it couldn't download a Go package

  - I think I fixed it by setting the env variable `GOPROXY="direct"`, or maybe it was a transient network issue

  - Source for that env var: <https://stackoverflow.com/questions/61856164/net-http-tls-handshake-timeout-when-importing-mongo-driver-golang>

- Unsurprisingly, Chrome is way too dang big

- You know what? I'm gonna stop using Yay and start using the AUR the way Arch intended

  - The stuff I did to install Yay is how to install any AUR package and set it up in pacman after

- I will install the tool `auracle`, which should make the whole process a bit easier

  - I accidentally uninstalled `yay` and `go` before installing `auracle`, so now I get to do it the truly manual way once more

    - The repo I need to clone is the one hosted by Arch, not the GitHub repo (AKA Upstream)

- Installing Fira Code font, because it showed up when I tried installing VS Code

  - Gotta add `"editor.fontLigatures": true` to my VS Code `settings.json`

  - Also, this made me realize it was time to add that file to my dotfiles, so I did!

- Then I added my custom ZSH prompt, a tweaked version of GNZH

- Alright, I think it is time to quit for the night. So much progress!

- Back to it this morning!

- I think it is getting to be time for prepping my laptop for the install

  - [Here's a list of the packages I've explicitly installed on the old Arch install](./crumbling_arch_pkglist.txt)

    - I made it with `pacman -Qqe >> list.txt`

      - [The source of that command, which also has instructions for installing from that list and stripping out AUR packages and such](https://ostechnix.com/create-list-installed-packages-install-later-list-arch-linux/)

  - [Here's one without the AUR](./crumbling_arch_pkglist_sans_aur.txt)

    - Generated with `comm -12 <(pacman -Slq | sort) <(sort crumbling_arch_pkglist.txt) >> crumbling_arch_pkglist.txt`

    - I think `pacman -Slq | sort` is generating the list of AUR packages

    - TIL I learned about `comm` (common lines?)

  - Fewer than I expected! Obviously, we won't need all the XFCE stuff

- A question I need to answer soon: should I return to doing a dual boot on this laptop, with Windows and Linux?

  - TBH, I'm not sure if there is any benefit...

  - However, I would like to set up the persistent USB to have the `osprober` package or whatever so other OSes show up in GRUB

- A side issue: the old USB 2.0 device I'm using is proving to be a poor choice.

  - Not enough space

  - I/O too slow for web browsing

- I don't have anything bigger, but I do have a 3.0 device that contains a Windows installer right now

  - There's not much point in preserving that, as it is surely years out of date by now

  - I will NEED to make a new one ASAP, because making Windows 10 install media outside of Windows is a fool's errand

- I'm realizing that I probably shouldn't be deleting the repos for my AUR packages...

  - They get updated by updating those repos, I think

  - That is one area where Auracle feels pretty weak...

---

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

---

- I think I understand the AUR and why they warn you about it much better this time around

  - When I was using Yay and not paying attention to sources, I was treating Cool Ranch Dude's git repo with the same deference as an official Arch one

  - That being said...I still feel like the installer scripts should have the option of installing Yay

    - it's big, but it is nice to be able to do stuff in the same syntax as Pacman if I've got the space

    - Maybe I'll learn Go to justify it...

## Part 3: Script It!

- I've already done this too many times, and until now without bothering to take any notes. Let's automate it!

- Yesterday I started working on a few scripts that aren't quite there

  - A partitioning one that is just a bunch of comments

  - A formatting one that is simple but untested

  - A mounting one that mostly works, though my optional "unmount" flag doesn't

    - I think the simplest solution for that particular problem is to make it a separate unmounting script

  - An over*arch*ing install script that calls the others

- I'd like to be able to specify (or check, I guess) if the target device is a USB drive

  - I don't think I'm going to make any swap space on future USBs, it isn't really necessary when the USB I/O is slower than writing to an SSD

    - (that is anecdotal)

- First things first, I'm splitting out the unmount device command into a separate thing

  - I'm converting the `-U` flag to represent a USB device

- I need to...learn how to do an `if` in bash

  - Re-learn, I guess

  - Also gotta re-learn how to do user prompts, which I think would be more elegant

    - Why let the user enter bad data?

- I'm regretting deleting my old `scripts` directory in setting up the dotfiles, I think I had a `dd_helper` that has examples of both those things

  - BRB, digging up another copy

    - ...Huh, that script isn't in the git repo I thought it was

    - Oh well, whatever

- I'm making progress, learning a bit about assigning variables based on flags and evaluating booleans in ifs

- AHHH, I think my issues are because I was specifying the option after my argument, it couldn't parse it

  - Easy fix!

- Cool, I think the unmounting script is almost finished...and it should be a good example for updating the others

- Gotta cite my sources, the scripts will need a bibliography of random google results I've smashed together:

  - <https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php>

  - <https://stackoverflow.com/questions/31974550/boolean-cli-flag-using-getopts-in-bash>

  - <https://www.mkssoftware.com/docs/man1/getopts.1.asp>

- Booleans have been giving me trouble, so I think I'll use good ol' 0s and 1s

  - That did the trick!

- Alright, the unmounting script seems to be all there!

- Now it is time to apply all those lessons to the mounting script, blech!

- It'd be nice to have a dry mode for all these scripts, but they're small enough that I can comment out the actual actions while testing

  - Speaking of testing, I'm not sure how you'd unit test scripts like this...

- I'm going to assume the device path is always the last option, so I can add more flags without having to do rewrites

  - Source for how to do so: <https://www.cyberciti.biz/faq/linux-unix-bsd-apple-osx-bash-get-last-argument/>

- That'll allow me to set up a dry mode at some point!

- The mount and unmount scripts are both fully functional!

- A quick QoL tweak to Gnome I have needed for literally years: <https://askubuntu.com/questions/69776/how-do-i-alt-tab-between-windows-using-gnome-3>

  - Presumably, another binary thing stuck in that `dconf` directory

- Time to bring the format script up to par with the rest

  - I won't do it just yet, but this and the partitioning script are begging for a "home" flag that at least gives the *option* of a separate home directory

- I'm pretty sure the format device script works, but I'm afraid to actually uncomment the actions

  - I feel like it needs a prompt to do something as serious as formatting a partition...

    - With a `-y` flag to override, of course!

- Ugh, time to learn how to make user prompts...

  - Not too bad!

    - Source: <https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php>

- ~~I'm really digging the `shellcheck` program and extension, it catches little stuff these tutorials don't have (like using `-r` instead of `-p`)~~

  - Actually, that seems to have been misleading advice, sticking with `-p`

- I made the prompt require the user type in the path of the device for extra caution

  - Now I need a `-y` override for scripting...

    - That'll be good practice at having multiple options

- The `-y` option is now present!

- Well, I've put it off as long as possible...time to write the partitioning script

  - I've been distracted by watching the Back to the Future Trilogy

- Once again, when I get to a partitioning script I really start to lose interest...probably because I did the whole thing with cgdisk before?

  - I *guess* I'll learn the gdisk commands...

  - Nahh, I'll assume the disk is already partitioned the way I expect and go from there

- I must admit to feeling a bit disheartened after googling "arch install script" and finding this:

  - <https://gist.github.com/magnunleno/3641682>

- Ahh well, time to move on to...making that Windows USB into the first install?

  - Sweet, that USB is actually ~16G!

- However, I am going to take another stab at partitioning, with hardcoded sizes

  - Turns out the proper tool to do it in a script is `sgdisk`

- I forgot how whiz-bang Back to the Future is, it has been a distracting few hours

- The `sgdisk` man page suggests 550M for swap, and they probably know more than me so I'll take that suggestion

  - It has excellent docs, actually!

- Alright, I *think* I have the partitioning process scripted out with `sgdisk`

  - Right now it is using hardcoded EFI and swap sizes, then filling the rest of the device

  - I think being able to specify a separate home directory is when specifying sizes will be more important

    - Or installing to something other than a USB when it comes to swap, I guess

- There is surely a better way to handle options in bash than what I'm doing currently with absolute indexes for parameters, but I don't know it yet...

- I suppose I'll...

  - test out the script with commented out actions

    - Seems to log the right stuff

      - Sidenote, I should stick some context into my logs (manually, obvs)

  - test out each command manually

  - Run it O_o

- Down the line, I think the confirmation prompts need to be moved up a few layers...at least to `prepare-hardware.sh`

- Alas, I think the unmounting script has become deprecated...

  - I almost feel like combining files would be beneficial to avoid repeating code everywhere...

    - That seems more like something to do once every piece has been shown to work on its own!

- Oh no, `mount` is ALSO deprecated!!

  - Well, I'll make sure the first two work, then combine them

- OH NO...I hadn't committed in a bit and I redirected into the wrong file...

  - Well...it was working well and logging nicely...

  - It was a lot faster the second time!

@import "./dry_run_partition_and_format_silently_with_swap.log"

- Alright, gonna glue the mount script into the format script

  - WAIT!

  - I should test the first two out before I do

- I started a real run of the script and...

  - Realized that I should *really* figure out how to output whatever that script command would output...

  - I should've run them externally at least once, so I'd know if they're hanging or just taking a normal amount of time...

  - I'm also...not sure how my script handles control C, aside from...not

    - `htop` to the rescue

- Alright, I am re-running the command and it just seems to be real slow

- Ended up rebooting to make sure everything is in a nice state

  - It seems to be that GPT really didn't like the fact it was a windows installer...

- I cheated a little and deleted the existing data in `cgdisk`

- Once I did that, `sgdisk --clear /dev/sdb` worked immediately (it hung before)

- Creating the system partition also worked successfully!

  - Well, not quite, I was mis-specifying the partition starts

- As a side bar, my Arch laptop has both an EFI and a boot partition, and the latter appears to contain the windows boot loader

  - That's a task for *way* down the line

- All the commands work!

  - The sectors aren't nicely aligned, though

    - `cgdisk` shows it most clearly, but it is also displayed in the embedded info about the flash drive after running the `sgdisk` commands

@import "./disk_info_after_manual_partitioning.txt"

- I should also name the partitions, with (I think) `-c`

  - Naming the partition didn't work with the `--largest-new` option, so I just used the equivalent `--new` arguments

- The partitioning script is fully functional!!

@import "./partition_silently_with_swap.log"

- Also, as a side note, it already outputs the output of the commands, it just wasn't earlier because the command was hanging...

- Hmm, re-running formatting on an already formatted disk causes a prompt that blocks me...

  - Ahh, forgot to create `/mnt/efi` before trying to put something there

- One last thing to fix, using `-F` when creating an `ext4` filesystem so it doesn't whine about a filesystem already being present

- `prepare-hardware.sh` is fully operational!

@import "./prepare_hardware_complete.log"

- So, what now?

  - I guess...pacstrapping the essentials?

- I can copy over my mirrorlist, which isn't actually done on the persistent USB I currently have

  - It is at `/etc/pacman.d/mirrorlist`

  - Wait, no, no need, `pacstrap` does that

    - says so right in the guide, should've trusted past Aileen...

- The `pacstrap` step works!

- It is time to `arch-chroot` in...

## TODO

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

  - Make one that partitions the device (`partition-device.sh`)

    - In progress, probably gonna be tricky
  
  - One that sets up the filesystems (`format-device.sh`)

    - Easy, assuming correct input

    - Not actually tested...

  - ~~Another that mounts the newly set up partitions~~ (`mount-device.sh`)

    - This script is also handy for re-mounting a device that was set up by the installer!

  - Another that does the pacstrapping, but with all the packages I've described in one go (if that is possible without errors)

  - Yet another for setting up GRUB for at least GPT

    - I don't think I even have a device to test MBR on...

  - One that sets up groups and makes a user

  - Then one that clones my dotfiles, installs Oh My Zsh, and stows everything

  - One that sets up locale
