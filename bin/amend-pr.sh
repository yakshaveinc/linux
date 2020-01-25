#!/usr/bin/env bash

USAGE="\
usage: amend-pr.sh <url>

example url https://github.com/hyperledger/fabric/pull/244

untested and most likely doesn't work on:
- PR in the same repo
- PR in renamed repo
"

if [[ $# -eq 0 ]]; then
  echo "${USAGE}"
  exit 1
fi


PR=$(basename "$1")
SRCDIR=/tmp/amend-pr-$PR
REPO=$(dirname "$(dirname "$1")")
PROJECT=$(basename "$REPO")


# -- echo helpers
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'        # no color

green() {
  declare arg1="$1"
  echo -e "${GREEN}$arg1${NC}"
}

red() {
  declare arg1="$1"
  echo -e "${RED}$arg1${NC}"
}

yellow() {
  declare arg1="$1"
  echo -e "${YELLOW}$arg1${NC}"
}
# /- echo helpers


green "..Getting username and branch for pushing.."

# value="abitrolly:patch-1" aria-label="Copied!"><sv
# -o, --only-matching
# -P, --perl-regexp
# https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
# -s - be silent
# -S - but show errors
NAMEBRANCH=$(curl -sS "$1" | grep -oP '(?<=value=").+?(?=" aria-label="Copy)' | head -1)
# abitrolly:patch-1
if [[ $NAMEBRANCH ]]; then
  yellow "$NAMEBRANCH"
else
  red "ERROR: can't parse branch name from GitHub markup"
  exit 255
fi
# https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split
NAME=${NAMEBRANCH%:*}    # remove :* from the end
BRANCH=${NAMEBRANCH#*:}  # remove *: from the beginning

RWREPO=git@github.com:$NAME/$PROJECT
green "..Cloning $RWREPO.."

git clone "$RWREPO" "$SRCDIR"
cd "$SRCDIR" || exit
#git fetch origin pull/$PR/head:pr-$PR
#git checkout pr-$PR
git checkout "$BRANCH"

green "..Adding upstream remote.."
echo -e "useful commands:"
yellow "  git rebase upstream/master"
git remote add upstream "$REPO"
git fetch upstream master

# ACK is an exit code used to confirm force push. it is derived from PR number
# by taking modulo, because exit codes can not be greater than 255
ACK=$PR
if (( PR > 256 )); then
  # taking modulo
  ACK=$(( PR % 256 ))
  if (( ACK == 0 )); then
    # 0 exit code also means user logged out normally. setting ACK to non-zero
    # value to avoid commit by mistake
    ACK=42
  fi
fi

green "Run 'exit $ACK' to commit and force push changes."
PS1="$SRCDIR (\$(git branch --show-current))$ " bash
RET=$?
if (( RET == ACK )); then
  green "Good! Pushing the PR"
  git push -f
else
  green "$RET != $ACK. Not pushing."
fi

