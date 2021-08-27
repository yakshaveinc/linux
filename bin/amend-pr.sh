#!/usr/bin/env bash

USAGE="\
usage: amend-pr.sh <url>

example url https://github.com/hyperledger/fabric/pull/244

untested and most likely doesn't work on:
- PR in renamed repo
"

if [[ $# -eq 0 ]]; then
  echo "${USAGE}"
  exit 1
fi


PR=$(basename "$1")
SRCDIR=/tmp/amend-pr-$PR
# https://github.com/hyperledger/fabric
REPO=$(dirname "$(dirname "$1")")
# fabric
PROJECT=$(basename "$REPO")
# hyperledger
ORG=$(basename "$(dirname "$REPO")")


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

PRHTML=$(curl -sS "$1")

# matching content
#     value="abitrolly:patch-1" aria-label="Copied!"><sv
#
# -o, --only-matching
# -P, --perl-regexp
# https://unix.stackexchange.com/questions/13466/can-grep-output-only-specified-groupings-that-match
# -s - be silent
# -S - but show errors
NAMEBRANCH=$(echo "$PRHTML" | grep -oP '(?<=value=").+?(?=" aria-label="Copy)' | head -1)
# now $NAMEBRANCH can be
# - empty               - regexp failed to parse
# - abitrolly:patch-1   - PR from another repo
# - py3-fixes           - PR from the same repo
if [[ -z $NAMEBRANCH ]]; then
  red "ERROR: can't parse branch name from GitHub markup"
  exit 255
fi
yellow "$NAMEBRANCH"
# https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
if [[ $NAMEBRANCH == *":"* ]]; then
   # https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split
   NAME=${NAMEBRANCH%:*}    # remove :* from the end
   BRANCH=${NAMEBRANCH#*:}  # remove *: from the beginning
else
   #SAMEREPO=true
   NAME="$ORG"
   BRANCH="$NAMEBRANCH"
fi

green "..Getting upstream branch for rebasing.."
# see above for explanation, also
# -A, --after-context=NUM   print NUM lines after match
# -m, --max-count=NUM
# matching content
#     commit into
#
#
#
#     <span title="buildpacks/docs:main"
UPSTREAM=$(echo "$PRHTML" | grep -A 4 -m 1 -P 'commits? into' | grep -oP '(?<=span title=")[^"]+')
# now $UPSTREAM is hyperledger/fabric:release-1.4
UPSTREAMBRANCH=${UPSTREAM#*:}  # remove *: prefix
yellow "$UPSTREAMBRANCH"


RWREPO=git@github.com:$NAME/$PROJECT
green "..Cloning $RWREPO.."

git clone "$RWREPO" "$SRCDIR"
cd "$SRCDIR" || exit
#git fetch origin pull/$PR/head:pr-$PR
#git checkout pr-$PR
git checkout "$BRANCH"

green "..Adding upstream remote.."
echo -e "useful commands:"
rebase() {
  green "..Running 'git rebase upstream/$UPSTREAMBRANCH'"
  git rebase "upstream/$UPSTREAMBRANCH"
}
# exporting functions and used variables for subshell
export -f green rebase
export GREEN NC UPSTREAMBRANCH
yellow "  rebase    - runs 'git rebase upstream/$UPSTREAMBRANCH'"
git remote add upstream "$REPO"
git fetch upstream "$UPSTREAMBRANCH"

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
PS1="\$PWD (\$(git branch --show-current))$ " bash
RET=$?
if (( RET == ACK )); then
  green "Good! Pushing the PR"
  git push -f
else
  green "$RET != $ACK. Not pushing."
fi

