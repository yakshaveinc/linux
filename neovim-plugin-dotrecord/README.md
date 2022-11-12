
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

Launching `neovim`.

Nothing happens.

