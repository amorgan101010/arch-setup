# Arch Boot USB Setup

## Preamble: Set up VS Code on Personal Computer

- This is where I am now!

- I can't seem to actually download the files I shared with myself via email, but I've at least got the basics.

- This font ugly AF too

- Anyway...

## Create Persistent Arch USB

- I think I can use GParted for this

  - Should I use the TUI version of it, to get some practice for later in the install?

  - Is that...`cparted`?

- I think it is `cgdisk`

  - Which is a TUI version of `fdisk`

- Ahh, when I say TUI I think I'm thinking of Curses

- I've deleted all the space currently on the disk

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
