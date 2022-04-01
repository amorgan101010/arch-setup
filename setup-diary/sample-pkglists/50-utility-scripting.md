<!-- markdownlint-disable MD041 -->
## Part 5. Random Utility Scripts

Because this Arch Setup repository is _totally_ the right place for a bunch of random bash scripts...

Seriously though, this repository has the "logging library" I made, and these bash scripts are good references for tasks I do fairly often.

### Convert To WAV

This script was written to convert a bunch of samples that are in OGG, FLAC, and MP3 formats to WAVs. This is necessary so I can put them into my Octatrack!

A potential refinement for this script would be doing a bit of research into the options FFMPEG has to offer, particularly with regards to bitrate/depth. I've worked with a few of the samples post-conversion, and unsurprisingly they're pretty gritty when I start tweaking them in the OT.

A spin-off related to the refinement above might be a script that deals with potential issues loading 44.1kHz samples into a project using 48kHz. I'm sure I read some forum thread on Elektronauts about the conversion being bad on-board...anyway, the script would just have to "upscale" the 44.1kHz to 48kHz WAVs "properly" (which would likely require digging up that thread).

### Partially Rename All Files in Directory

This script originates from another sample pack (classic). This time I had the option to download them all from BandCamp in WAV format! But the person who made the library gave each file an incredibly long name. Such as:

- `denzelworldpeace - DENZELWORLDPEACE MONOMACHINE SAMPLEPACK - 50 RUBBER BAND.wav`

I want to reformat it like:

- `DWP-MnM-50 RUBBER BAND.wav`

And maybe get rid of the spaces in it while I'm in there & learning about string splitting in Bash.

I imagine this script will be pretty easy to adapt for use with any set of files that needs renaming. It would be cool if I could generalize the code for "iterate over each file in this directory and do something to it" into a library that accepts a function for the "do something to the file" part, since I seem to be doing that in most scripts. Maybe there is even a more elegant way of doing it built in to Bash!
