ctrl-branch-command() {
  git branch -vvv
}

# bind ctrl-b to type string
bindkey -s '^b' 'ctrl-branch-command\n'
