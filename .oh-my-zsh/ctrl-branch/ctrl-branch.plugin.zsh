
# https://wiki.zshell.dev/community/zsh_handbook
# https://gist.github.com/ClementNerma/1dd94cb0f1884b9c20d1ba0037bdcde2
# https://helpful.wiki/zsh/

ctrl-branch-command() {
  # read `git branch` command
  CMD=$(git branch -vvv --color=always)
  # split command by newline into array using f parameter expansion
  # https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  MENU=( ${(f)CMD} )

  local BRANCHES=()
  local HOTKEYS=()
  # traverse non-colored lines, detect branch and hotkey
  CMD_NOCOLOR=$(print $CMD | sed -e 's/\x1b\[[0-9;]*m//g')
  NCLINES=( ${(f)CMD_NOCOLOR} )
  i=1
  for v in $NCLINES; do
    ## get branch name
    # strip the column with current branch marker
    branch=${v[3,-1]}
    # cut after space
    branch=${branch%% *}
    BRANCHES+=($branch)

    ## assign shortcuts
    # XXX when no shortcut found, assign free number then letter
    # [m] always main
    if [[ $branch == "main" || $branch == "master" ]]; then
      HOTKEYS+=("m")
    else
      IDX=0
      for ((n=1; n < ${#branch}; n++)) {
        char=$branch[$n]
        if [[ $char == "m" ]]; then
          continue
        fi
        # if $char is in $HOTKEYS
        IDX=$HOTKEYS[(I)$char]
        if [[ $IDX == 0 ]]; then
          HOTKEYS+=($char)
          break
        fi
      }
      # if no shortcut found, assign placeholder
      if [[ $IDX != 0 ]]; then
        HOTKEYS+=("_")
      fi
    fi
  done

  #HOTKEYS+=($i)
  #((i++))

  ## show menu
  # highlight shortcut letter inline in yellow
  # XXX preserve existing color after highlight
  i=1
  for m in $MENU; do
    key=$HOTKEYS[$i]
    hot=$fg_bold[yellow]$key$reset_color
    # replace key in branch name with highlight
    branch=$BRANCHES[$i]
    hotbr=${branch/$key/$hot}

    print ${m/$branch/$hotbr}

    # as alternative place symbol first on the line
    #print $hot $m
    ((i++))
  done

  # read $keypress
  # https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html#index-read
  read -s -k keypress

  IDX=$HOTKEYS[(I)$keypress]
  if [[ $IDX == 0 ]]; then
    # printf "%q\n" $keypress
    if [[ $keypress != $'\n' && $keypress != $'\033' ]]; then
      #print "Key: $IDX #keypress"
      printf "Undefined key: %q\n" $keypress
    fi
  else
    BRANCH=$BRANCHES[$IDX]
    git switch $BRANCH
  fi
}

# bind ctrl-b to type string
bindkey -s '^b' 'ctrl-branch-command\n'
