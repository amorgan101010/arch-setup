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


