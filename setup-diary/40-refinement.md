<!-- markdownlint-disable MD041 -->
## Part 4. Refinement

### 2021-05-11

- Dishearteningly, I discovered yesterday that an official Arch Linux installer was released very recently :/

  - <https://www.youtube.com/watch?v=F3t3yqUvWSo>

- I'll want to install `tlp` for power management

  - I'll also want to configure it so it doesn't auto-power off USB devices

### 2021-05-18

- UGH, I am trying out Solarized Light for a while and it is like looking at a negative

  - I am trying it out because it will be a bit easier to look at in sunlight, and I want to work outside!

- As for "refinements", I think I stand at the junction of many paths

- To most efficiently explore said maps, it would be prudent to start using VMs to test the install

  - The biggest advantage that will provide is the ability to create snapshots...why re-do all the other stuff if I just want to test the user script stuff?

  - Luckily, I figured out how to set up VirtualBox at some point in the past!

    - Eventually, that is the sort of finicky setup I'll want to document and automate for a possible future install

- It would also be nice to figure out how to create an ISO out of my installer...

  - I wonder if ISOs can be done in multiple layers, kinda like a Docker image

  - On that note, it would also be nice to get a Docker image of my install going!

- One last "path of convenience" is adding some flags to the installer scripts so far

  - At the very least, make the GUI optional

- I suppose adding the GUI flag has the best ratio

  - Ratio of what?

  - Hmm...usefulness/effort

    - A nice example was me falling down a rabbithole trying to figure out how to LaTeX that ratio up

      - Not terribly useful, would require learning how to do multiple things

      - ...that being said, it'd be pretty sick if I was able to easily embed LaTeX into my markdown

      - I wonder if BitBucket can render LaTeX? GitHub?

- Anyway; on to a gooey flag!

---

@import "./41-driver-detour.md"

---

- Ideally at some point I will be able to actually re-do the install on my laptop

  - I don't want to lose my current install as a reference, but it is broken in subtle ways that a reinstall will likely remedy...

  - Now that my laptop has a usable battery, making it super pleasant to use is paramount!

- My brain is overflowing with tasks that need prioritizing

  - This leads to the metatask of needing to implement some sort of task management system

- I've dabbled in Task Warrior...and I know of a few other custom systems!

- Also, I think this particular repo's diary has outlived its usefulness for some tasks...I need a blog!

### 2021-05-19

- I think it is getting pretty close to being time to eat my own dog food and actually re-do my laptop install (preserving my home directory, of course)

  - Stuff is gonna break, what else is new?

- I guess I'll want to do that home backup from an install USB

  - Better bust out my blanks bag!

  - I will also need to decide if I want to just copy, or do a full imaging

    - The former sounds like less of a detour

      - A...`dd`etour

- I'm going to assume that this isn't going to be my final install...

  - I don't want to figure it out right now, but the final install should definitely have a separate `/home` partition so it too can be backed up.

- A sidebar, but at some point in my recent tweaks to my current Arch install, Gnome's file manager became my default and now USB devices automount 😕

  - The shiny of GNOME is wearing off

    - `bspwm` time 😎

- On a more serious note, I've got yet another thing I'd like to do *at some point*

  - Add comments documenting why I'm installing various packages in the package lists

    - [Also, update the commands that read from those lists to handle comments](https://www.reddit.com/r/archlinux/comments/5tw1r0/can_i_get_pacman_to_install_list_of_packages_from/)

- I tried pointing my script as-is at the USB device, fresh out of the bag, and it error'd

  - I think it is unable to parse whatever partitioning the device came with

  - Ideally, that sort of thing wouldn't need to be adjusted before running those commands
  
  - That said, I just re-made the partition table in Gparted because I already spent a weekend messing with partitions

  - Gparted should definitely be part of my GUI package list...

- I think doing a laptop reinstall is still a bit premature unfortunately...

  - There'd be a lot of weird, messed up stuff, like a poorly installed grub

- In a more manageable move, I've set up the comment ignoring in the install scripts

- I suspect the AUR helper make step is failing because I am missing a necessary dependency

  - If all the dependencies are installed, it shouldn't prompt me for a password and fail because there is no password

- In adding comments to the package lists, I lose any sort of easy alphabetization

- What if I had a separate file for each category, named something like `documentation.pkglist.txt`

- Alternately, I could start to incorporate the note namespaces from [this article](https://www.kevinslin.com/notes/3dd58f62-fee5-4f93-b9f1-b0f0f59a9b64.html)

  - `Gui.DesktopEnvironment.pkglist.txt`

  - `Base.Documentation.pkglist.txt`

- It probably wouldn't be too much of a pain to whip up a new script that "manages" the individual lists

  - With a script like that, I might have more flexibility in selecting exactly what packages to install down the line

  - I think it can be done with some combination of grepping, globbing, and redirecting

- With that goal somewhere in mind, I'm removing the `LITE` flag from the script

- Also, I want a higher-level "install" script that calls prepare-chroot to fully distinguish between the two

- I think I need to improve my command parsing, at least at the top level of the install script

  - I want to use long arguments!

    - [I'm starting at this stack overflow post](https://stackoverflow.com/questions/12022592/how-can-i-use-long-options-with-the-bash-getopts-builtin)

    - [...and immediately heading over to the nice resource linked within](http://mywiki.wooledge.org/BashFAQ/035)

- I'm starting to think of what I could accomplish with error handling...

  - I wonder if there is a way to do it in bash that isn't reinventing the wheel?

  - If there isn't, is there a language that is good for doing this sort of stuff that does have error handling?

- There seems to be a wealth of information about bash error handling, which is cool

  - all I *really* need is to be able to throw!

- [A SO Start](https://stackoverflow.com/questions/64786/error-handling-in-bash)

- One thing I have immediately learned, thanks to a comments-section argument, is that I should be using lowercase variables

  - Uppercase appears to be for ~~system~~ shell builtins and env vars only: <https://stackoverflow.com/questions/64786/error-handling-in-bash#comment7342157_185900>

  - Done! Ended up using the VS code find and replace tool

- I'm going to add a write flag to the installer and then pass it along

- Without the flag, nothing happens other than logs

### 2021-05-20

- Alright, time to pass down the flag!

- First up is `prepare-chroot.sh`

- Gotta say, on a new day with (technically) fresh eyes, I'm really digging the choice to make variables snake/lower cased...

- I either need to learn to use `getopts` properly or bite the bullet and roll my own argument parser (or maybe introduce external bash libraries?)

  - AKA, the stuff I was reading about last night

- `prepare-chroot` is actually the most involved, since it has a bunch of sub "modules" (that are really just other scripts)

  - If I really do want to start being a bash pro, I'll probably want to source scripts rather than just running them like I would the command line

    - Then again, that's probably getting away from the original intent of this repo, documenting my arch install

      - ...but getting closer to my new goal of getting bash-savvy!

- I'm gonna move the last bit of the prepare script into a new `bootstrap` script

- If I wanted to make things a little less hardcoded, I'd pass in the root mount path to the bootstrap script

  - TODO immediately after wiring the bootstrap script up

- I also kinda want to set up my own custom logger that takes context and a message...

- Setting a context variable once based on the file name is WAY cleaner!

```bash
context=$(basename "$0");
```

- I just realized, creating my own Arch container would probably be as easy as pointing my scripts at a base image!!

  - Which is good motivation for creating a non-gui option immediately

- If I had a docker image, working on this would become significantly more portable

  - It'd just be a matter of re-opening VS Code within the container!

    - I would be pretty surprised if doing the `prepare-chroot` is possible without getting pretty in-depth

- Typing out all this about Docker containers is also reminding me that I can pretty easily test `within-chroot` and beyond 

- I could wrap the chroot-specific steps in yet another script, or I could add a chroot flag...

  - I prefer the latter, but *yet again* I am in need of a better option parser

- I guess keeping each file pretty small will help with picking one to start...

- Oh, wait, I was implementing some context logging

- I guess I want to make a file that has just a function I source elsewhere, rather than a script...

  - what are the best practices for that?

    - Is that a...lib?

      - I think I will stick it in a folder with that name...it is one function in a library of them

- *Anyway*, here's a nice resource for sourcing functions, which seems more appropriate for where I'm at: <https://linuxize.com/post/bash-source-command/>

- I think I get the point of running the installer in a chroot now, it'd be cool to ignore everything outside my little test env

- Had to add a custom argument to my shellcheck extension...

  - <https://stackoverflow.com/questions/58587756/why-does-shellcheck-fail-when-a-source-file-is-representing-the-variables-at-the>

- My `log.sh` module is nearly syntactically identical to the echoes I was already doing...

  - But it is a start at using modules over scripts!

- I think I can apply this pattern to a universal args parser!

- A future plan, to be sure, but I was just thinking about how neat it would be to model synth patches...

  - I think I am re-inventing the sequencer...
  
    - I think approaching a sequencer from this angle would be easier for me personally!

    - My brain is overflowing with visions of totally sick Amiga-style demo software that could be interacted with live and spews out ascii art and such...

- As far as updating the logging goes, I've learned how to replace from the current line to the end of the file in `vim`...

```sed
:.,$s/find/replace/g
```

- The big takeaway is replacing `%` with `.,$`

  - Which feels *right* in a Unix way

    - ...but it didn't work

      - ...because I forgot the `s`

- I'm kinda at the point in my VS Code proficiency where it'd be cool to easily save snippets at both the workspace and project level

- I don't want to set up my new log lib in the scripts after I chroot in just yet, because I'd have to update what I copied in a bit

  - I think I'll want to copy this whole dang repo into the new device

    - Which will require updating every reference to a file after chrooting in...

- I think I have reached the point where I am reinventing state

### 2021-05-21

- The Auracle make process was failing because it wanted to install some dependencies...here's what it depends on:

```bash
Depends On     : pacman  libcurl.so  libsystemd
Makedepends    : meson  git  perl  systemd
Checkdepends   : gtest  gmock
```

- IDK what the difference between those three categories is...

- Well, I can find out pretty quick...
  
  - but I want to set up a chroot for testing first.

- If I set up `bootstrap.sh` to accept a destination mount, it'll do the thing...

- It seems to be working properly with the custom chroot path I gave it!

- Eventually, it'd be nice for the installer to have a `--prepare-hardware` flag that requires a device path

  - If that's not provided, I guess it'd require a mount path? Or maybe it could be optionally specified with `/mnt` as default...

- Another thing - I should probably call `unmount.sh` at the end of `install.sh`

  - That would probably only occur if `--prepare-hardware` was specified, if that exists by then

- A related-ish note about mounts and chroots:

  - When I'm testing using a random directory, rather than a separate filesystem, I need to bind it to itself to make `pacstrap` happy

  - `mount --bind /chroots/installer-test /chroots/installer-test`

- All in all, going from an empty folder to running the installer inside a chroot created there requires:

```bash
mount --bind /chroots/installer-test /chroots/installer-test
./bootstrap.sh -w /chroots/installer-test
arch-chroot /chroots/installer-test /arch-setup/within-chroot.sh
```

- I got an error I'm not sure if is because of the chroot or what...

  - "grub-install: error: failed to get canonical path of `/efi'"

- Ohh, pacman kindly told me the missing dependencies of the aur helper

  - meson

  - gtest

  - gmock

- The user password stuff also kinda seems to be failing...

  - Ahh, understandably so, I was setting it to the username

- Even after installing the dependencies, the auracle build is failing on some arcane and ungoogleable error

- I think I need a flag in `within-chroot` that determines whether grub stuff is set up or not

  - Like half the stuff in that script is probably unnecessary for non-physical installs (AKA Docker or a test chroot)

- I tried running everything against a flash drive, and it got pretty far!

- I'm reading a bit about LVM, as I know nothing about it but I think it would be extra pro (and also maybe prevent partitioning issues like I have on both my laptops)

- In the process, I learned `wipefs` exists to clean up pre-existing disk signatures...which might be the missing piece of my partition script!

- Speaking of the partition script, I am trying to bring it up to snuff and pass in a write flag

- It seems to have done a beautiful job re-partitioning the USB!

- Wow, I found an explanation of the ~1MB of space between partitions from the author of `sgdisk`!

  - <https://superuser.com/a/663870>

- Ahh...I've passed down the write flag in all the hardware-related scripts (which, really, are the ones that should've had it first!)

  - All that is left is `within-chroot`

- But first, some fun with logs...I want to add colors, they're ugly!

  - [Obligatory SO post about it](https://stackoverflow.com/a/20983251)

- `tput` seems rad!

- I might add the device path to the logs where it is used, too...that would clean things up a bit!

### 2021-05-23

- Working on this Arch installer has reminded me of the fun of Linux tinkering in general...

  - I'm thinking of my past attempts at setting up an audio/midi network (before I really used midi, but the audio definitely "worked")

    - That is not a rabbit hole I feel comfortable going down until *at least* this installer has reached the point I call it 1.0.0

- Home media networking is a bit easier, though!

- I installed the program `chiaki` from the AUR, and it worked almost perfectly for streaming from my PS4

  - It worked fine when I tested it in my room, but the signal was juuuust too weak to work well when gaming from the back deck

    - Which kinda makes me want to set up a second router or reposition the current one, but that is off topic

- Now I feel pretty confident about the utility of setting up my gaming laptop as a streaming device

  - Both because I know the network is strong enough for it in-room, and because my Arch laptop is much easier to drop in to my desk setup thanks to similar size and port configuration

- Also, I wanna check in on how Proton is doing!

  - ...not that my gaming laptop works properly with Linux :'(

- Well, one thing I am immediately remembering about Proton is its appetite for disk space...probably shouldn't mess with it on the arch laptop and stick to the in-home streaming

- There are a few wrinkles in doing in-home streaming conveniently with what I have available to me right now...

  - I can't find any unused ethernet cables

  - Even if I did have one, I am out of free ports on the router

- The latter problem *could* be pretty easily solved, *if* I had all of my electronics supplies with me

  - Alas, I can picture exactly where my network switch is, at my mom's house...

- Well, *another* fun networking idea I had was maybe setting up an Arch build server

- As a sort of adjacent thought, I should pick up a few modern Raspberry Pis rather than continuing to use my first-gen one

- Wowzer, there's a Pi 4 now and it has EIGHT GIGS OF RAM

  - Mine has 512M...

  - I think mine had less internal storage space than the new one has in RAM alone

- All that being said, mine was also *far* cheaper than the newest pi 4

  - I guess a 3 would *probably* do all I want...

    - Which is primarily pi-hole, and other things from there

- I also forgot the pain of having to buy a case...

- Huh, I guess the 3B+ only has 1G of RAM, big jump!

- I guess I don't have much choice but to hold off on advanced home networking, til I address the various issues above...

- As for setting up my gaming laptop (AKA my PC from this point forward), I've decided to sacrifice the PlayStation's ethernet for now...

  - For some reason, the laptop couldn't connect when I plugged the ethernet in directly...

    - Luckily, I have a spare ethernet to USB adapter! (and even more, in a drawer near my network switch...)

- A perk of having the PC in its own special place is that there is room to attach my funky little exhaust fan cooler

- For some reason, I am receiving no audio when streaming...

  - Is that true of every game?

- Also, it doesn't seem to want to stay full screen...I think when the streaming resolution drops, things aren't adapting properly

- Y'know, I am now remembering similar resolution issues in Dark Souls 2 when I tried hooking it up to other devices previously

- Assuming I do get everything working, there's no real reason to keep the PC in my room - might as well move it to the front room

  - I know it was at one point, I think I switched to Gnome specifically to play GTA Vice City with remote play

  - Speaking of that game, I guess it might be more likely to be stolen from the front room...which I'd call a good thing, but I have a lot of files on there

    - No reason to rush to things, I like having a flexible ethernet cable that can be swapped between the PS4 and PC (and any future devices I might try setting up)

- Getting things to remain fullscreen was as easy as checking the Gnome keybindings and discovering it isn't F11 like I expected (and indeed, it is unset)

- Hmm, the old optiplex that has been sitting in my closet for a year unexpectedly booted up when I turned it on...

  - Last time I checked, it was dead!

- It will be a nice candidate for my installer scripts :D

  - Currently, it has Xubuntu...probably because I happened to have a Xubuntu disk laying around when I set it up

    - The hard drive seems to be toast (it dropped me into recovery mode right after I tried booting), but that's no biggie

- First, a nice motive to actually run the full installer AND attempt to boot it after...

  - Second, a nice test of portability

  - Third, I could maybe try installing to the toast drive just for lulz to see how the flash drive is as an installer

    - I can see that going either way, it's possible my arch laptop has some subtle thing I'm not thinking of

- It would be pretty sweet if I could use my old Optiplex as the server it was always meant to be!

- Assuming everything "just works" to the point I can immediately access the network, I will need to set up the machine for SSH so I don't have to be next to it or plug in a keyboard or anything

  - I will also want to document said process and incorporate it into the installer (probably part of `as-user`)

- The installer made it to attempting to run `./within-chroot` and failed, because that is no longer where the file lives

  - I updated the installer to point in the right place, and I'm running that step manually in the hopes everything past that is fine (I'm almost cert)

    - Alas, no, my pkglist organization has come to bite me!

- Dang, I need to restart :/

- Maaaybe it'll work this time?

- Something interesting I noticed is that the chroot logs aren't colorized...

  - I wonder if they would become colorized after installing some particular package?

- It would be nice to have "undo" scripts for this part of the process, though I fear they would become unmaintained

- Presumably this install is going to take even longer, because it should actually get to the stage where it installs Gnome and such

- I wonder if installing X is still "necessary" with Gnome, now that it uses Wayland?

- I have been sorta looking at used computers on Craigslist, which is always a very dangerous game for me

  - There are, of course, incredible sounding deals

- Perhaps a more productive thing to do while I wait on the installer would be scripting some stuff around the package lists

- The installer has gotten all the way to installing GUI packages without issue!

- Bash fileparsing resources:

  - <https://www.digitalocean.com/community/tutorials/workflow-loop-through-files-in-a-directory>

  - <https://www.cyberciti.biz/faq/bash-get-basename-of-filename-or-directory-name/>

  - <https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash>

  - <https://linuxhint.com/bash_lowercase_uppercase_strings/>

- Wow, I forgot just how long the installer takes when it actually works...

  - Code makes it much slower, unfortunately

  - Hopefully it shares some dependencies with Chrome...which I wish I had included, now

    - Oh that's right, it is AURful

- Daaaang, I think the whole install worked...

- This is worth sticking into a log file!

  - Uhh, never mind, it is far longer than my history goes back

- I guess it is time for the second moment of truth, plugging it in!

- Somewhat unsurprisingly, it did not work

  - I suppose I am a fool for thinking the optiplex would support GPT!

- I...don't really want to re-do that whole hour + process...

  - I guess I'll need to skip the GUI next time :P

- I think I will need to alter a few different scripts to support MBR...

- All that said, MBR actually seems way simpler (fingers crossed)

- Ugh, tweaking the partitioning script to do MBR is gonna be a pain and a half...

- Hmmmm, the Arch Wiki claims I can covert the existing USB install to MBR with `sgdisk -m /dev/sda`

- I have to assume I also need to do something with Grub...

  - `grub-install --target=i386-pc /dev/sdb`

    - When I tried this, I got an error like `grub-install: warning: this GPT partition label contains no BIOS Boot Partition; embedding won't be possible.`

    - I found this SO: <https://superuser.com/questions/660309/live-resize-of-a-gpt-partition-on-linux>

    - Adding a BIOS Boot type partition with `cfdisk` made the command work

      - Also, I cheated and shrunk the existing root partition with GParted

      - I think I am technically doing a BIOS/GPT setup now

  - `grub-mkconfig -o /boot/grub/grub.cfg`

    - This worked without issue, though I must say I feel wary about the fact I didn't have to mount the boot partition first...

- OMG, it is booting now!!

  - I still need to update the scripts...but knowing I can create bootable media with multiple partitioning schemes is pretty badass!

- It even tried to check the journal on the shot disk in the PC (and gave up after a timeout)

- The boot media is running quite slowly on the optiplex, which is not super surprising...

- Like, logging in to the TTY is taking multiple minutes slow

  - Actually, it kinda seems like my shell is broken

- But still! These things are symptoms of running GNOME on an ancient Optiplex, I think

- As a bit of a bookmark - I need to finish implementing BIOS stuff in `partition.sh` and then keep working my way down the scripts after it

  - Also, maybe script the conversion between boot loaders?
  
    - Or make my install compatible with both by default?

    - That would be a good place to have a `--removable` flag...

### 2021-09-09

- Something I am running into on my current install that should be mitigated by this installer:

- The 96.1 MB `boot` partition only has about 4MB remaining, and I keep getting annoying warnings about it

- Surely I can spare the space to (at least) double that going forward.

- Also, that warning is kinda putting the heat back on to actually finish this project!

- It would be kinda nice to do a trial run of this on my optiplex, but I'd prefer to get a proper disk drive for it rather than rely on USB long term

- Ideally, the optiplex would not need a gui...it just needs to be a media server, and maybe a pi-hole