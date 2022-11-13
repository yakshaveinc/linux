
### Plug-in

Making this dir symlink to `neovim` plugin dir.
```
ln --symbolic "$PWD" ~/.local/share/nvim/site/pack/neovim-plugin-dotread
```

* [ ] configure shorter plugin path, like `~/.plugins` (I don't know how)
* [ ] hack Neovim to autodiscover `~/.plugins` (I don't know how)

### Checking that plugin works

(I don't know how)

Creating `example.lua` with simple print.
```lua
print("halo")
```

Launching `neovim`..

Nothing happens.

### Telling Neovim go get it

```sh
touch NEOVIM
```

Staring it again..

Nothing.

### Making it through the environment

```sh
NVIM="load plugin ." nvim
```

Nah. Doesn't work.

```sh
NVIM="load plugin example.lua" nvim
```

Same.

### Back to the 2022

Okay, Google..

```sh
VIMINIT="lua print('halo')" nvim
```

This. Prints. 'halo'

### Right link

`runtimepath` is longcat. Fix it.

```sh
LUAPLUGINPATH="$HOME/.local/share/nvim/site/pack/dirsomany/start/neovim-plugin-dotread"
mkdir -p "$LUAPLUGINPATH"
ln --symbolic "$PWD" "$LUAPLUGINPATH"/plugin
```

Prints. And committed.

### Seppuku

```sh
./NEOVIM
```

