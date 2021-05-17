<!-- markdownlint-disable MD041 -->
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