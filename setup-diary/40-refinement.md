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
