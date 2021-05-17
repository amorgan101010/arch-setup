<!-- markdownlint-disable MD041 -->
<!-- markdownlint-disable MD026 -->
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

@import "./logs/dry_run_partition_and_format_silently_with_swap.log"

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

@import "./logs/disk_info_after_manual_partitioning.txt"

- I should also name the partitions, with (I think) `-c`

  - Naming the partition didn't work with the `--largest-new` option, so I just used the equivalent `--new` arguments

- The partitioning script is fully functional!!

@import "./logs/partition_silently_with_swap.log"

- Also, as a side note, it already outputs the output of the commands, it just wasn't earlier because the command was hanging...

- Hmm, re-running formatting on an already formatted disk causes a prompt that blocks me...

  - Ahh, forgot to create `/mnt/efi` before trying to put something there

- One last thing to fix, using `-F` when creating an `ext4` filesystem so it doesn't whine about a filesystem already being present

- `prepare-hardware.sh` is fully operational!

@import "./logs/prepare_hardware_complete.log"

- So, what now?

  - I guess...pacstrapping the essentials?

- I can copy over my mirrorlist, which isn't actually done on the persistent USB I currently have

  - It is at `/etc/pacman.d/mirrorlist`

  - Wait, no, no need, `pacstrap` does that

    - says so right in the guide, should've trusted past Aileen...

- The `pacstrap` step works!

- It is time to `arch-chroot` in...

- How do I handle that in a script?

- About how I expected, a second script for inside the chroot

- I don't want to keep waiting for pacstrapping to happen, I'm going to write down as much chroot stuff as possible and hope I get close on the first shot

- Breaking the rules and editing sudoers with `sed`

  - Source: <https://stackoverflow.com/questions/10420713/regex-pattern-to-edit-etc-sudoers-file>

  - ...Nah

- A safer solution: <https://www.reddit.com/r/archlinux/comments/9ms3ad/adding_wheel_allall_all_defaults_rootpw_into/>

- I'm at the point this is becoming a real pain to test...

- It made it to the second round of installs this time (and is still going)!

- One change left to make to the script I forgot about:

  - Setting the time zone

  - Probably pretty similar to doing it in a Docker container, so NBD!

### 2021-05-10

- My first attempt to clone something with git also has a fingerprint prompt that needs skipping

- It got almost all the way! But failed on cloning my Dotfiles and exited :/

  - It should boot now, though!

- I guess seeing if what I have now builds is as good a test as any!

- A note from after booting in:

  - I think all the repo cloning into my home directory has to be done as my non-root user

- It is still failing on repo cloning, but just about everything else still works!

  - I should enable the desktop manager /greeter way earlier, so a failure to clone doesn't prevent it from being enabled

  - It should *eventually* happen after user creation, or be hidden behind a flag

- The GUI part of the installer is HUGE!

  - All the more reason to hide it behind a flag

- The GUI installer pretty much "just works," but most of the stuff done as the non-root user fails...mainly the cloning of repos and the installation of Oh-My-ZSH/Auracle

  - Perhaps I should create a third script of user-specific commands?

    - I'll try that, if nothing else it'll be cleaner to look at...

- That totes did it, just a few more small path cleanup things!

- Got *so* close this time!

- Just a few failures...

  - Couldn't `stow oh-my-zsh` because there was already a `.zshrc` present

    - Is the OMZ installer not respecting the flag I passed it or what?

    - TBH, I should probably be using something from pacman rather than curling a random script...

  - Couldn't make `auracle` because it prompts for sudo package

    - Don't think I can run makepkg as root

    - It suggests `either use the -S option to read from standard input or configure an askpass helper`

- About all that is left is user-space (IDK if I am using that term correctly) setup, which feels like it can go into a new section.

