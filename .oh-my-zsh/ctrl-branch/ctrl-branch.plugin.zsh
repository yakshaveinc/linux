
# https://wiki.zshell.dev/community/zsh_handbook
# https://gist.github.com/ClementNerma/1dd94cb0f1884b9c20d1ba0037bdcde2

ctrl-branch-command() {
  # read `git branch` command
  CMD=$(git branch -vvv --color=always)
  # split command by newline into array using f parameter expansion
  # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  MENU=( ${(f)CMD} )
  # traverse array and print line by line
  for v in $MENU; do
    print $v
  done
}

# bind ctrl-b to type string
bindkey -s '^b' 'ctrl-branch-command\n'
