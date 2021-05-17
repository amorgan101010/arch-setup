<!-- markdownlint-disable MD041 -->
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

@import "./21-design-detour.md"

---

- I think I understand the AUR and why they warn you about it much better this time around

  - When I was using Yay and not paying attention to sources, I was treating Cool Ranch Dude's git repo with the same deference as an official Arch one

  - That being said...I still feel like the installer scripts should have the option of installing Yay

    - it's big, but it is nice to be able to do stuff in the same syntax as Pacman if I've got the space

    - Maybe I'll learn Go to justify it...